void Main() {
    IntroMessage = IntroMessage.Replace("<3", Icons::Heartbeat);
    startnew(WatchEditor);
    startnew(InitButtons);
    // startnew(WatchComputeShadowsIntercept);
}

void WatchEditor() {
    bool prevEditorNull = true;
    while (true) {
        yield();
        auto editor = cast<CGameCtnEditorFree>(GetApp().Editor);
        if (editor is null) {
            prevEditorNull = true;
            continue;
        }
        bool resolutionChanged = int(screenWH.x) != Draw::GetWidth() || int(screenWH.y) != Draw::GetHeight();
        if (prevEditorNull || resolutionChanged) {
            // run setup
            ConfigEditorUI();
            g_EditorLabelsDone = false; // redo labels
        }
        prevEditorNull = false;
        CheckEditorLabels(editor);
        CheckEditorLightmap(editor);
        CheckHideMapInfo();
        CheckAutoHideInventory(editor);
    }
}

void CheckEditorLightmap(CGameCtnEditorFree@ editor) {
    if (S_LM_ForceLowQuality) {
        editor.PluginMapType.NextMapElemLightmapQuality = CGameEditorPluginMap::EMapElemLightmapQuality::Lowest;
        editor.PluginMapType.ForceMacroblockLightmapQuality = true;
    }

    /* shadows stuff */
    bool lightOn = !S_LM_DisableShadows; // game default: true
    bool lmOnly = S_LM_DisableShadows; // game default: false
    bool shadowGen = !S_LM_DisableShadows; // game default: true

    // main daylight light
    auto mainLight = editor.GameScene.HackScene.Lights[1];
    mainLight.IsActive = lightOn; // not sure if this helps, but it doesn't break lighting
    // mainLight.Light.LightMapOnly = false;
    mainLight.Light.LightMapOnly = lmOnly; // not sure if this helps
    // mainLight.Light.IsShadowGen = true;
    mainLight.Light.IsShadowGen = shadowGen; // this turns off shadows cast by blocks

    // lights that effect highlight details or something
    auto highlightsLight = editor.GameScene.HackScene.Lights[0];
    highlightsLight.IsActive = lightOn;
    highlightsLight.Light.LightMapOnly = lmOnly;
    highlightsLight.Light.IsShadowGen = shadowGen;
    if (S_LM_EnableUltra) Set_LM_QUltra(); // only run this if we're going to set it to true, otherwise it'll be disabled when the setting value changes.
    if (S_LM_SizeMax1k) Set_LM_SizeMax();
}

void Set_LM_QUltra() {
    try {
        auto disaplaySettings = GetApp().Viewport.SystemConfig.Display;
        disaplaySettings.LM_QUltra = S_LM_EnableUltra;
    } catch {
        warn('exception getting display settings: ' + getExceptionInfo());
    }
}

void Set_LM_SizeMax() {
    try {
        auto disaplaySettings = GetApp().Viewport.SystemConfig.Display;
        disaplaySettings.LM_SizeMax = S_LM_SizeMax1k
            ? CSystemConfigDisplay::ELightMapSizeMax::_LightMapSizeMax_1k_2
            : CSystemConfigDisplay::ELightMapSizeMax::_LightMapSizeMax_Auto;
    } catch {
        warn('exception getting display settings: ' + getExceptionInfo());
    }
}

CControlContainer@ GetFrameMain(CGameCtnApp@ app) {
    try {
        auto editor = cast<CGameCtnEditorFree>(app.Editor);
        auto uiSuperRoot = cast<CControlFrameStyled>(editor.EditorInterface.InterfaceRoot);
        auto frameMain = cast<CControlContainer>(uiSuperRoot.Childs[0]);
        return frameMain;
    } catch {
        warn("exception getting main frame: " + getExceptionInfo());
        return null;
    }
}

void CheckHideMapInfo() {
    auto frameMain = GetFrameMain(GetApp());
    if (frameMain is null) return;
    auto challengeParams = cast<CControlFrame>(frameMain.Childs[7]);
    if (challengeParams is null) return;
    challengeParams.IsHiddenExternal = S_HideMapInfo;
    challengeParams.IsVisible = !S_HideMapInfo;
}

bool g_EditorLabelsDone = false;
uint lastMobilsLength = 0;
uint lastForceOn = 0;
void CheckEditorLabels(CGameCtnEditorFree@ editor, bool force = false) {
    // we need to run this frequently b/c elements are added/removed as the UI changes
    // if (g_EditorLabelsDone) return;

    if (editor.EditorInterface.InterfaceScene is null) return;
    auto scene = editor.EditorInterface.InterfaceScene;
    if (scene is null) return;

    if (lastForceOn + 2000 < Time::Now) {
        force = true;
        lastForceOn = Time::Now;
    }

    // method 1, via scene.Mobils: doesn't always update immediatley with check but is performant; 1.5 ms checking Id.Name, 1.0 ms checking Id.Value
    if (true) {
        if (!force && lastMobilsLength == scene.Mobils.Length) return;
        for (uint i = 0; i < scene.Mobils.Length; i++) {
            auto mobil = scene.Mobils[i];
            if (mobil.Id.GetName() != "EntryInfos") continue;
            // if (mobil.Id.Value != 0x40005b9b) continue; // changes each launch it seems
            mobil.IsVisible = S_ShowBlockLabels;
        }
    }
    /*
    // method 2, via InterfaceRoot, works perfectly, but ~1ms per frame, breaks with g_EditorLabelsDone check
    else if (true) {
        // if (g_EditorLabelsDone) return;
        auto root = cast<CControlFrameStyled>(editor.EditorInterface.InterfaceRoot);
        if (root is null) return;
        // root > FrameMain > FrameInventories
        auto frameInv = cast<CControlFrame>(root.Childs[0]).Childs[0];
        RecurseSetLabelVisibility(frameInv);
    } // method 3, via InterfaceRoot but like 20 ms per frame, breaks with g_EditorLabelsDone check
    else if (false) {
        // if (g_EditorLabelsDone) return;
        auto root = cast<CControlFrameStyled>(editor.EditorInterface.InterfaceRoot);
        if (root is null) return;
        // root > FrameMain > FrameInventories
        auto frameInv = cast<CControlFrame>(root.Childs[0]).Childs[0];
        // RecurseSetLabelVisibility(node);
        array<CControlBase@> nodes = {frameInv};
        for (uint i = 0; i < nodes.Length; i++) {
            auto node = nodes[i];
            auto name = node.Id.GetName();
            if (name.StartsWith("Pager")) continue;
            if (name.StartsWith("TopRight")) continue;

            auto frame = cast<CControlFrame>(node);

            if (name == "ListCardArticles") {
                auto childs = cast<CControlListCard>(node).ListCards;
                for (uint j = 0; j < childs.Length; j++) {
                    nodes.InsertLast(childs[j]);
                }
            } else if (frame !is null) {
                auto childs = frame.Childs;
                for (uint j = 0; j < childs.Length; j++) {
                    nodes.InsertLast(childs[j]);
                }
            }

            if (name == "EntryInfos") {
                node.IsVisible = S_ShowBlockLabels;
            }
        }
    } */

    g_EditorLabelsDone = true;
    lastMobilsLength = scene.Mobils.Length;
}

void RecurseSetLabelVisibility(CControlBase@ el) {
    auto frame = cast<CControlFrame>(el);
    if (frame !is null) {
        for (uint i = 0; i < frame.Childs.Length; i++) {
            RecurseSetLabelVisibility(frame.Childs[i]);
        }
    }
    if (el.Id.GetName() == "EntryInfos") {
        el.IsVisible = S_ShowBlockLabels;
    }
}

void CheckAutoHideInventory(CGameCtnEditorFree@ editor) {
    // note: don't exit early if the setting is disabled b/c we don't want to keep IsHiddenExternal true if the setting is disabled
    if (editor is null) return;
    /* thought this worked, mb sometimes, but didn't work when trying it this time
    // editor.PluginMapType.HideInventory = !g_MouseHoveringInventory;
    */
    auto frameMain = cast<CControlContainer>(editor.EditorInterface.InterfaceRoot.Childs[0]);
    if (frameMain is null) return;
    auto frameInventories = cast<CControlContainer>(frameMain.Childs[0]);
    if (frameInventories is null) return;
    if (g_MouseHoveringInventory) {
        frameInventories.IsVisible = true;
    } else if (S_AutoHideInventory) {
        frameInventories.IsHiddenExternal = true;
    }
}

[Setting hidden]
float S_InventoryFocusTimeoutSeconds = 1.9;

uint lastTimeFocused = 0;
bool IsInventoryFrameFocused(vec2 pos) {
    bool defaultResp = Time::Now - lastTimeFocused < uint(S_InventoryFocusTimeoutSeconds * 1000);
    bool mouseInActiveArea = IsWithin(pos, inventoryAreaPos, inventoryAreaSize);
    if (mouseInActiveArea) {
        lastTimeFocused = Time::Now;
        return true;
    }
    try {
        auto frameMain = cast<CControlContainer>(cast<CGameCtnEditorFree>(GetApp().Editor).EditorInterface.InterfaceRoot.Childs[0]);
        if (frameMain is null) return defaultResp;
        auto frameInv = cast<CControlContainer>(frameMain.Childs[0]);
        if (frameInv is null) return defaultResp;
        bool isFocused = frameInv.IsFocused;
        if (isFocused) lastTimeFocused = Time::Now;
        return isFocused || defaultResp;
    } catch {
        return defaultResp;
    }
}

/* MAIN EDITOR UI CONFIG STUFF */

mat3 uiScaleUVs;
mat3 uiTranslateUVs;
mat3 uiToUVs;
mat3 uvsToUi;
vec2 uiPosPx;
vec2 uiSizePx;
vec2 uiWH;
bool matriciesInitialized = false;
vec2 screenWH;
vec2 hoverAreaSize;
vec2 hoverAreaPos;
vec2 inventoryAreaSize;  // for autohide
vec2 inventoryAreaPos;  // for autohide

[Setting hidden]
float S_HoverFontSize = 50;

void ConfigEditorUI() {
    auto editor = cast<CGameCtnEditorFree>(GetApp().Editor);
    if (editor is null) {
        trace('no editor');
        return;
    }

    screenWH = vec2(Draw::GetWidth(), Draw::GetHeight());

    vec2 oMin = S_EditorDrawBounds.xyz.xy;
    vec2 oMax = vec2(S_EditorDrawBounds.z, S_EditorDrawBounds.w);

    if (S_DrawEditorFullscreen) {
        oMin = vec2(-1, -1);
        oMax = vec2(1, 1);
    }

    editor.EditorInterface.InterfaceScene.OverlayMin = oMin;
    editor.EditorInterface.InterfaceScene.OverlayMax = oMax;

    uiWH = (oMax - oMin);
    uiScaleUVs = mat3::Scale(uiWH / 2.);
    // vec2(1, 1) * uiWH
    // uiTranslateUVs = mat3::Translate(vec2(( - oMax.x / 2. - oMin.x / 2.), - oMax.y / 2. - oMin.y / 2.));
    uiTranslateUVs = mat3::Translate((oMax * -1. - oMin) / 2.);
    uiToUVs = uiTranslateUVs * uiScaleUVs;
    uvsToUi = mat3::Inverse(uiToUVs);

    matriciesInitialized = true;
    // after matricies set

    // uiPosPx = UvToScreen((uiToUVs * vec3(-1, -1, 1)).xy)
    uiPosPx = UICoordsToScreen(vec2(-1, -1));
    uiSizePx = ScaleUvToPixels(uiWH);

    CalculateHoverAreaSize();

    // enough to cover the variant blocks on the LSH (e.g. the platform alts)
    // complete coverage: .85, partial (enough with timeout) .7, with generous timeout .4
    float inventoryHoverHeight = .3;
    inventoryAreaSize = ScaleUvToPixels((uiScaleUVs * vec3(2, inventoryHoverHeight, 1)).xy);
    inventoryAreaPos = UICoordsToScreen(vec2(-1, 1. - inventoryHoverHeight));

    if (S_HoverIsSimilarlyScaled)
        S_HoverFontSize = Math::Min(screenWH.x, screenWH.y) / 30.;

    while (fullscreenBtn is null || resizeDragBtn is null) yield();
    auto uvBtnSize = ScaleUvToPixels((uiScaleUVs * vec3(0.1, 0.1, 1)).xy);
    uvBtnSize.y = Math::Max(30., Math::Min(uvBtnSize.x, uvBtnSize.y));
    uvBtnSize.x = uvBtnSize.y;
    vec2 trCorner = uiPosPx + vec2(uiSizePx.x, 0) + vec2(-1, 1) * btnMargin;
    auto resizeBtnPos = trCorner - vec2(uvBtnSize.x, 0);
    auto posBtnPos = resizeBtnPos - vec2(uvBtnSize.x + btnMargin.x, 0);
    auto fullscreenBtnPos = posBtnPos - vec2(uvBtnSize.x + btnMargin.x, 0);
    fullscreenBtn.size = uvBtnSize;
    fullscreenBtn.pos = fullscreenBtnPos;
    resizeDragBtn.size = uvBtnSize;
    resizeDragBtn.pos = resizeBtnPos;
    posDragBtn.size = uvBtnSize;
    posDragBtn.pos = posBtnPos;
}

void CalculateHoverAreaSize() {
    if (S_HoverIsSimilarlyScaled) {
        hoverAreaSize = ScaleUvToPixels((uiScaleUVs * vec3(uiWH.x, uiWH.y, 1)).xy);
        // In effect, apply this twice to make a similar scaled down version
        hoverAreaPos = UICoordsToScreen((uiToUVs * vec3(0, 0, 1)).xy - uiWH / 2.);
        return;
    }

    if (!S_HoverManualSize) {
        // automatic sizing
        hoverAreaSize = uiSizePx * (S_HoverAutoSizePercent / 100.);
        if (S_HoverAutoSizeEnableMinimum) {
            hoverAreaSize.x = Math::Max(hoverAreaSize.x, S_HoverAutoSizeMinimumPx.x);
            hoverAreaSize.y = Math::Max(hoverAreaSize.y, S_HoverAutoSizeMinimumPx.y);
        }
    } else {
        // manual sizing
        hoverAreaSize = S_HoverSize;
    }

    if (!S_HoverManualPosition) {
        // automatic positioning
        vec2 alignMult = vec2(float(uint(S_HoverHorizAlign)) / 2., float(uint(S_HoverVertAlign)) / 2.);
        vec2 offset = hoverAreaSize * alignMult;
        vec2 pos = uiPosPx + uiSizePx * alignMult - offset;
        hoverAreaPos = pos;
    } else {
        // manual positioning
        hoverAreaPos = UICoordsToScreen(S_HoverUiUvPosition);
    }
}


void UpdateEditorSizeFromDrag() {
    // calc TR corner from mouse cursor
    vec2 targetPosNew = g_LastMousePos + vec2(1, -1) * (resizeDragBtn.size + btnMargin) / 2.;
    vec2 newBounds = ScreenToUv(targetPosNew) * -1.;
    newBounds.x = Math::Max(newBounds.x, -1);
    newBounds.y = Math::Min(newBounds.y, 1);
    S_EditorDrawBounds.x = newBounds.x;
    S_EditorDrawBounds.w = newBounds.y;
    ConfigEditorUI();
}

void UpdateEditorPosFromDrag() {
    vec2 targetPosNew = g_LastMousePos + vec2(1, -1) * (vec2(1.5, .5) * (resizeDragBtn.size + btnMargin)) - vec2(uiSizePx.x, 0);
    targetPosNew.x = Math::Min(Draw::GetWidth(), targetPosNew.x + uiSizePx.x) - uiSizePx.x;
    targetPosNew.x = Math::Max(0, targetPosNew.x);
    targetPosNew.y = Math::Min(Draw::GetHeight(), targetPosNew.y + uiSizePx.y) - uiSizePx.y;
    targetPosNew.y = Math::Max(0, targetPosNew.y);
    auto newBounds = ScreenToUv(targetPosNew);

    vec2 oMin = S_EditorDrawBounds.xyz.xy;
    vec2 oMax = vec2(S_EditorDrawBounds.z, S_EditorDrawBounds.w);
    vec2 oDiff = oMax - oMin;

    S_EditorDrawBounds.z = - newBounds.x;
    S_EditorDrawBounds.x = S_EditorDrawBounds.z - oDiff.x;
    S_EditorDrawBounds.w = - newBounds.y;
    S_EditorDrawBounds.y = S_EditorDrawBounds.w - oDiff.y;
    ConfigEditorUI();
}


bool g_MouseHoveringInventory = false;
bool g_HoveringOverEditor = false;
vec2 g_LastMousePos;
uint g_LastEditorHoverTime = 0;
[Setting hidden]
uint S_EditorHoverTimeout = 200;

/** Called whenever the mouse moves. `x` and `y` are the viewport coordinates.
*/
void OnMouseMove(int x, int y) {
    auto editor = cast<CGameCtnEditorFree>(GetApp().Editor);
    if (editor is null) return;
    if (!matriciesInitialized) return;
    vec2 pos = vec2(x, y);
    g_LastMousePos = pos;
    bool activelyHovering = IsWithin(pos, hoverAreaPos, hoverAreaSize)
        || (g_HoveringOverEditor && IsWithin(pos, uiPosPx, uiSizePx));
    g_HoveringOverEditor = S_AlwaysShowEditor || activelyHovering || (Time::Now - g_LastEditorHoverTime < S_EditorHoverTimeout);
    if (activelyHovering) g_LastEditorHoverTime = Time::Now;
    g_MouseHoveringInventory = g_HoveringOverEditor && (
        IsInventoryFrameFocused(pos)
    );
    for (uint i = 0; i < buttons.Length; i++) {
        buttons[i].UpdateMouse(pos);
    }
}

vec2 btnMargin = vec2(10, 10);

NvgButton@[] buttons;
NvgButton@ fullscreenBtn;
NvgButton@ resizeDragBtn;
NvgButton@ posDragBtn;

[Setting hidden]
bool S_DrawEditorFullscreen = false;

// Alternatives: Icons::Expand   , Icons::SearchPlus  , Icons::Plus
const string fsBtnLabelExpand = Icons::PlusCircle;
// Alternatives: Icons::Compress , Icons::SearchMinus , Icons::Minus
const string fsBtnLabelReturn = Icons::MinusCircle;

void ResetFullscreen() {
    S_DrawEditorFullscreen = false;
    fullscreenBtn.label = fsBtnLabelExpand;
}

void InitButtons() {
    @fullscreenBtn = NvgButton();
    fullscreenBtn.label = fsBtnLabelExpand;
    @fullscreenBtn.onClick = function(NvgButton@ btn) {
        S_DrawEditorFullscreen = !S_DrawEditorFullscreen;
        fullscreenBtn.label = S_DrawEditorFullscreen ? fsBtnLabelReturn : fsBtnLabelExpand;
        ConfigEditorUI();
    };

    @resizeDragBtn = NvgButton(vec2(100, 100), vec2(50, 50), Icons::Expand);
    @resizeDragBtn.onDrag = function(NvgButton@ btn) {
        UpdateEditorSizeFromDrag();
        ResetFullscreen();
    };

    @posDragBtn = NvgButton();
    posDragBtn.label = Icons::Arrows;
    @posDragBtn.onDrag = function(NvgButton@ btn) {
        UpdateEditorPosFromDrag();
        ResetFullscreen();
    };

    buttons.InsertLast(fullscreenBtn);
    buttons.InsertLast(resizeDragBtn);
    buttons.InsertLast(posDragBtn);
}

void DrawButtons() {
    for (uint i = 0; i < buttons.Length; i++) {
        buttons[i].Draw();
    }
}

/** Called whenever a mouse button is pressed. `x` and `y` are the viewport coordinates.
*/
UI::InputBlocking OnMouseButton(bool down, int button, int x, int y) {
    auto editor = cast<CGameCtnEditorFree>(GetApp().Editor);
    if (editor is null) return UI::InputBlocking::DoNothing;
    bool isLeftBtn = button == 0;
    if (!isLeftBtn) return UI::InputBlocking::DoNothing;
    auto mousePos = vec2(x, y);
    g_LastMousePos = mousePos;
    bool blockClick = false;
    for (uint i = 0; i < buttons.Length; i++) {
        blockClick = blockClick || (!down && buttons[i].IsClicked); // releasing a clicked button
        auto hovered = buttons[i].UpdateMouse(mousePos, down ? MouseUpdateClick::Down : MouseUpdateClick::Up);
        blockClick = blockClick || (down && hovered); // clicking a button
    }
    return blockClick ? UI::InputBlocking::Block : UI::InputBlocking::DoNothing;
}


bool IsWithin(vec2 pos, vec2 topLeft, vec2 size) {
    vec2 d1 = topLeft - pos;
    vec2 d2 = (topLeft + size) - pos;
    return (d1.x >= 0 && d1.y >= 0 && d2.x <= 0 && d2.y <= 0)
        || (d1.x <= 0 && d1.y <= 0 && d2.x >= 0 && d2.y >= 0)
        || (d1.x <= 0 && d1.y >= 0 && d2.x >= 0 && d2.y <= 0)
        || (d1.x >= 0 && d1.y <= 0 && d2.x <= 0 && d2.y >= 0)
        ;
}

/** Called every frame. `dt` is the delta time (milliseconds since last frame).
*/
void Update(float dt) {
    if (cast<CGameCtnEditorFree>(GetApp().Editor) is null) {
        g_HoveringOverEditor = false;
    }
    for (uint i = 0; i < buttons.Length; i++) {
        buttons[i].IsVisible = g_HoveringOverEditor;
    }
}

/** Render function called every frame.
*/
void Render() {
    if (S_ShowDebugRegions) {
        DrawDebugAutoHideInventory();
    }

    if (!matriciesInitialized) return;
    if (GetApp().Editor !is null) {
        if (GetApp().CurrentPlayground !is null) return; // when in test mode
        auto editor = cast<CGameCtnEditorFree>(GetApp().Editor);
        // when editing an item this becomes CGameEditorItem
        if (editor is null) return;

        // auto elInventory = cast<CControlFrame>(editor.EditorInterface.InterfaceRoot.Childs[0]).Childs[0];
        auto elMainUI = editor.EditorInterface.InterfaceRoot.Childs[0];
        auto elMLOverlay = editor.EditorInterface.InterfaceRoot.Childs[8];
        array<CControlBase@> els = {elMainUI, elMLOverlay};
        for (uint i = 0; i < els.Length; i++) {
            auto el = els[i];
            if (g_HoveringOverEditor) {
                el.IsVisible = true;
                // el.DrawBackground = false;
            } else {
                el.IsHiddenExternal = true;
            }
        }
        DrawButtons();
        if (g_HoveringOverEditor) {
            ShowEditorWindowBounds();
        } else {
            // since the editor isn't visible we want to tell the user:
            DrawIndicatorOverlay();
        }
    }
}

/** uv: vec2 with components in range [-1,1] */
vec2 UvToScreen(vec2 uv) {
    return uv * screenWH / 2. + screenWH / 2.;
}

vec2 ScreenToUv(vec2 pos) {
    return (pos - screenWH / 2.) * 2. / screenWH;
}

// vec2 ScaleScreenToUv(vec2 size) {
//     return size * 2. / screenWH;
// }

vec2 UICoordsToScreen(vec2 ui) {
    return UvToScreen((uiToUVs * vec3(ui.x, ui.y, 1)).xy);
}

vec2 ScreenCoordsToUI(vec2 pos) {
    auto uvPos = ScreenToUv(pos);
    return (uvsToUi * vec3(uvPos.x, uvPos.y, 1)).xy;
}

vec2 ScaleUvToPixels(vec2 uv) {
    return uv / 2. * screenWH;
}

// vec2 ScaleUiUvToPixles(vec2 ui) {
//     return ScaleUvToPixels((uiToUVs * vec3(ui.x, ui.y, 1)).xy);
// }


const string HoverMsg = "Hover to Show UI";

void DrawIndicatorOverlay() {
    nvg::Reset();
    nvg::BeginPath();
    nvg::Rect(hoverAreaPos, hoverAreaSize);
    nvg::FillColor(S_HoverFillColor);
    nvg::Fill();
    nvg::StrokeColor(S_HoverStrokeColor);
    nvg::StrokeWidth(S_HoverStrokeWidth);
    nvg::Stroke();
    nvg::ClosePath();
    nvg::TextAlign(nvg::Align::Center | nvg::Align::Middle);
    nvg::FontFace(nvgDroidSans);
    nvg::FontSize(S_HoverFontSize);
    auto textWidth = hoverAreaSize.x * 0.7;
    auto textBs = nvg::TextBoxBounds(hoverAreaSize.x * 0.7, HoverMsg);
    vec2 textPos = hoverAreaPos + vec2(hoverAreaSize.x - textWidth, hoverAreaSize.y + S_HoverFontSize - textBs.y) / 2.; // - textBs; // + textBs;
    nvg::FillColor(S_HoverTextColor);
    nvg::TextBox(textPos, hoverAreaSize.x * 0.7, HoverMsg);
}

void ShowEditorWindowBounds() {
    if (!matriciesInitialized) return;
    nvg::Reset();
    nvg::BeginPath();
    nvg::Rect(uiPosPx, ScaleUvToPixels(uiWH));
    // nvg::FillColor(vec4(1., .5, .0, .1));
    // nvg::Fill();
    nvg::StrokeColor(S_EditorIndicatorStrokeColor);
    nvg::StrokeWidth(S_EditorIndicatorStrokeWidth);
    nvg::Stroke();
    nvg::ClosePath();
}

void OnSettingsChanged() {
    // print('settings changed');
    ConfigEditorUI();
}

bool Vec4Eq(vec4 a, vec4 b) {
    return true
        && a.x == b.x
        && a.y == b.y
        && a.z == b.z
        && a.w == b.w
        ;
}

bool Vec2Eq(vec2 a, vec2 b) {
    return true
        && a.x == b.x
        && a.y == b.y
        ;
}

vec3 V2ToAffine(vec2 v) {
    return vec3(v.x, v.y, 1);
}

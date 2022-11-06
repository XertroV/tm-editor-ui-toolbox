void Main() {
    IntroMessage = IntroMessage.Replace("<3", Icons::Heartbeat);
    startnew(WatchEditor);
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
        if (prevEditorNull) {
            // run setup
            ConfigEditorUI();
            g_EditorLabelsDone = false; // redo labels
        }
        prevEditorNull = false;
        // todo
        CheckEditorLabels(editor);
        CheckEditorLightmap(editor);
        CheckHideMapInfo();
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
}

CControlContainer@ GetFrameMain(CGameCtnApp@ app) {
    auto editor = cast<CGameCtnEditorFree>(app.Editor);
    auto uiSuperRoot = cast<CControlFrameStyled>(editor.EditorInterface.InterfaceRoot);
    auto frameMain = cast<CControlContainer>(uiSuperRoot.Childs[0]);
    return frameMain;
}

void CheckHideMapInfo() {
    auto frameMain = GetFrameMain(GetApp());
    auto challengeParams = cast<CControlFrame>(frameMain.Childs[7]);
    challengeParams.IsHiddenExternal = S_HideMapInfo;
}

bool g_EditorLabelsDone = false;
uint lastMobilsLength = 0;
void CheckEditorLabels(CGameCtnEditorFree@ editor) {
    // we need to run this frequently b/c elements are added/removed as the UI changes
    // if (g_EditorLabelsDone) return;

    if (editor.EditorInterface.InterfaceScene is null) return;
    auto scene = editor.EditorInterface.InterfaceScene;
    if (scene is null) return;

    // method 1, via scene.Mobils: doesn't always update immediatley with check but is performant; 1.5 ms checking Id.Name, 1.0 ms checking Id.Value
    if (true) {
        if (lastMobilsLength == scene.Mobils.Length) return;
        // todo
        for (uint i = 0; i < scene.Mobils.Length; i++) {
            auto mobil = scene.Mobils[i];
            // if (mobil.Id.GetName() != "EntryInfos") continue;
            if (mobil.Id.Value != 0x40005b9b) continue;
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

float nvgFontSize = 50;

void ConfigEditorUI() {
    auto editor = cast<CGameCtnEditorFree>(GetApp().Editor);
    if (editor is null) {
        trace('no editor');
        return;
    }

    screenWH = vec2(Draw::GetWidth(), Draw::GetHeight());

    vec2 oMin = S_EditorDrawBounds.xyz.xy;
    vec2 oMax = vec2(S_EditorDrawBounds.z, S_EditorDrawBounds.w);
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

    hoverAreaSize = ScaleUvToPixels((uiScaleUVs * vec3(uiWH.x, uiWH.y, 1)).xy);
    hoverAreaPos = UICoordsToScreen((uiToUVs * vec3(0, 0, 1)).xy - uiWH / 2.);

    nvgFontSize = Math::Min(screenWH.x, screenWH.y) / 30.;
}


bool g_HoveringOverEditor = false;

/** Called whenever the mouse moves. `x` and `y` are the viewport coordinates.
*/
void OnMouseMove(int x, int y) {
    if (GetApp().Editor is null) return;
    if (!matriciesInitialized) return;
    // max x -> left; min x -> right
    // max y -> top; min y -> bottom
    // multiply mouse UV by -1:
    // max x -> right; max y -> bottom -- IN MOUSE COORDS
    // then usual region check
    // auto screenWH = vec2(Draw::GetWidth(), Draw::GetHeight());
    // vec2 mouseUV = (vec2(x, y) - screenWH * 0.5) / screenWH * -1;
    g_HoveringOverEditor = S_AlwaysShowEditor || (g_HoveringOverEditor
        ? IsWithin(vec2(x, y), uiPosPx, uiSizePx)
        // ? mouseUV.x > S_EditorDrawBounds.x && mouseUV.x < S_EditorDrawBounds.z
        // && mouseUV.y > S_EditorDrawBounds.y && mouseUV.y < S_EditorDrawBounds.w
        : IsWithin(vec2(x, y), hoverAreaPos, hoverAreaSize)
    )
        ;
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

/** Render function called every frame.
*/
void Render() {
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

vec2 UICoordsToScreen(vec2 ui) {
    return UvToScreen((uiToUVs * vec3(ui.x, ui.y, 1)).xy);
}

vec2 ScaleUvToPixels(vec2 uv) {
    return uv / 2. * screenWH;
}

/** ui: vec2 with transformed-uv coords; maps (-1,1) -> range(ui._) */
vec2 UiToUv(vec2 ui) {
    return ui;
    // auto s = .5;
    // auto scale = mat3();
    // scale.xx = -s;
    // scale.yy = -s;
    // scale.zz = 1;
    // auto trans = mat3();
    // trans.xx = 1;
    // mat3::Scale(s);
    // mat3::Translate(vec2())
}

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
    nvg::FontFace(nvgMontSemiBold);
    nvg::FontSize(nvgFontSize);
    auto textWidth = hoverAreaSize.x * 0.7;
    auto textBs = nvg::TextBoxBounds(hoverAreaSize.x * 0.7, HoverMsg);
    vec2 textPos = hoverAreaPos + vec2(hoverAreaSize.x - textWidth, hoverAreaSize.y + nvgFontSize - textBs.y) / 2.; // - textBs; // + textBs;
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

vec4 EditorBounds_TL_Q = vec4(0, 0, 1, 1);
vec4 EditorBounds_TR_Q = vec4(-1, 0, 0, 1);
vec4 EditorBounds_BR_Q = vec4(-1, -1, 0, 0);
vec4 EditorBounds_BL_Q = vec4(0, -1, 1, 0);
vec4 EditorBounds_FS_Q = vec4(-1, -1, 1, 1);
vec4 EditorBounds_Center_Q = vec4(-.5, -.5, .5, .5);

[Setting hidden]
vec4 S_EditorDrawBounds = EditorBounds_BL_Q; // bottom left
// vec4 S_EditorDrawBounds = vec4(0, -0, 1, 1); // top left
// vec4 S_EditorDrawBounds = vec4(-1, 0, 0, 1); // top right
// vec4 S_EditorDrawBounds = vec4(-1, -1, 1, 1); // full screen

[Setting hidden]
bool S_HideMapInfo = false;

[Setting hidden]
bool S_ShowBlockLabels = false;

[Setting hidden]
bool S_AlwaysShowEditor = false;

[Setting hidden]
bool S_AutoHideInventory = false;

[Setting hidden]
bool S_ShowDebugRegions = false;

const string TTIndicator = "  \\$888" + Icons::QuestionCircle + "\\$z";


[SettingsTab name="Introduction" icon="QuestionCircleO"]
void S_RenderIntroTab() {
    RenderIntro();
}


[SettingsTab name="Editor UI" icon="Expand"]
void S_RenderUIScaleTab() {
    vec4 orig_EditorDrawBounds = vec4(S_EditorDrawBounds);
    bool orig_ShowBlockLabels = S_ShowBlockLabels;

    Heading("Editor UI Options");
    S_EditorHoverTimeout = uint(UI::SliderFloat("Editor UI Hide Timeout (s)" + TTIndicator, S_EditorHoverTimeout / 1000., 0, 3.) * 1000.);
    AddSimpleTooltip("How long the mouse needs to spend outside the editor UI region for the UI to automatically hide.");

    S_AlwaysShowEditor = UI::Checkbox("Always Show Editor UI? \\$f84Unsafe for mapping!\\$z" + TTIndicator, S_AlwaysShowEditor);
    AddSimpleTooltip("You will experience phantom UI clicks if you leave this on.\nIt's useful while adjusting the editor UI region, though.");

    S_HideMapInfo = UI::Checkbox("Hide Map Info?" + TTIndicator, S_HideMapInfo);
    AddSimpleTooltip("Hides the green box in the top left that shows map name,\nauthor, coppers cost, and validation status.\n(Sets FrameChallengeParams.IsVisible = false)");

    S_ShowBlockLabels = UI::Checkbox("Show All Block Labels in Inventory?" + TTIndicator, S_ShowBlockLabels);
    AddSimpleTooltip("This will enable labels for the folders / blocks in the inventory.\nThese aren't usually visible.\nTo disable, you might need to restart the editor/game.");

    S_AutoHideInventory = UI::Checkbox("Auto-hide the Inventory? (Auto TAB)" + TTIndicator, S_AutoHideInventory);
    AddSimpleTooltip("This will auto-hide the inventory (blocks / items / macroblocks / etc) when the mouse\nis not hovering over it, and re-show it when the mouse enters that region again.\nUseful in fullscreen mode. Also helps with phantom misclicks.");
    if (S_AutoHideInventory) {
        S_InventoryFocusTimeoutSeconds = UI::SliderFloat("Inventory Auto-hide Timeout (s)", S_InventoryFocusTimeoutSeconds, 0., 3.);
    }
    // if (UI::BeginChild("timeout child")) {
    //     UI::BeginDisabled(!S_AutoHideInventory);
    //     UI::EndDisabled();
    // }
    // UI::EndChild();

    S_ShowDebugRegions = UI::Checkbox("Draw Debug Regions?" + TTIndicator, S_ShowDebugRegions);
    AddSimpleTooltip("This will draw the regions where hover things activate if they are invisible.\n(E.g., the auto-unhide inventory activation region)");

    Heading("Editor UI Quick Settings");
    QuickSetting_Bounds(EditorBounds_FS_Q, "Fullscreen (Standard Editor)");
    QuickSetting_Bounds(EditorBounds_BL_Q, "Bottom Left Quarter (Default)");
    QuickSetting_Bounds(EditorBounds_TL_Q, "Top Left Quarter");
    QuickSetting_Bounds(EditorBounds_TR_Q, "Top Right Quarter");
    QuickSetting_Bounds(EditorBounds_BR_Q, "Bottom Right Quarter");
    QuickSetting_Bounds(EditorBounds_Center_Q, "Center of Screen", false);

    Heading("Editor UI Size/Location");

    UI::TextWrapped("You can set a custom editor UI scale and placement using these sliders.");
    UI::TextWrapped("Note: they are not very intiutive. Use the quick settings buttons above to get a feel. Ctrl + click the sliders to set an exact value.");
    UI::TextWrapped("You might find it easier to drag the " + Icons::Arrows + " and " + Icons::Expand + " buttons to dynamically move and resize the editor, respectively.");
    VPad(.25);
    if (UI::BeginTable("pos/size", 2, UI::TableFlags::SizingFixedFit)) {
        UI::TableNextColumn();
        UI::Text("Editor UI Position:");
        UI::TableNextColumn();
        UI::Text(uiPosPx.ToString());
        UI::TableNextColumn();
        UI::Text("Editor UI Size:");
        UI::TableNextColumn();
        UI::Text(uiSizePx.ToString());
        UI::EndTable();
    }
    VPad(.5);


    S_EditorDrawBounds.x = UI::SliderFloat("OverlayMin x", S_EditorDrawBounds.x, -1, S_EditorDrawBounds.z);
    S_EditorDrawBounds.y = UI::SliderFloat("OverlayMin y", S_EditorDrawBounds.y, -1, S_EditorDrawBounds.w);
    S_EditorDrawBounds.z = UI::SliderFloat("OverlayMax x", S_EditorDrawBounds.z, S_EditorDrawBounds.x, 1);
    S_EditorDrawBounds.w = UI::SliderFloat("OverlayMax y", S_EditorDrawBounds.w, S_EditorDrawBounds.y, 1);


    if (!Vec4Eq(orig_EditorDrawBounds, S_EditorDrawBounds)) {
        startnew(OnSettingsChanged);
    }

    if (orig_ShowBlockLabels != S_ShowBlockLabels) {
        g_EditorLabelsDone = false;
    }
}

[Setting hidden]
bool S_HoverIsSimilarlyScaled = true;

[SettingsTab name="Hover Indicator" icon="HandPointerO"]
void S_RenderHoverTab() {
    Heading("Hover Indicator");
    S_HoverIsSimilarlyScaled = UI::Checkbox("Automatically Manage?" + TTIndicator, S_HoverIsSimilarlyScaled);
    AddSimpleTooltip("The hover indicator is similarly scaled to the editor UI.\nIf the editor UI is in the bottom left of the screen,\nthe hover indicator is in the bottom left of the editor UI region.\nIf the editor is 25% of the screen's area and in the center-middle of the screen,\nthen the hover indicator is 25% of the UI's area and in the center-middle of the editor UI region.\nIf the Editor UI is fullscreen, then the hover indicator is also fullscreen.");
    UI::TextWrapped("This will scale the hover indicator based on Editor UI Scaling. It works well for an editor that takes up 1/4 of the screen.");
    VPad(0.25);
    UI::Text("Manage color settings in the appearance tab.");
    UI::BeginDisabled(S_HoverIsSimilarlyScaled);
    DrawHoverCustomizations();
    UI::EndDisabled();
}

[Setting hidden]
bool S_HoverManualPosition = false;

[Setting hidden]
vec2 S_HoverUiUvPosition = vec2(-1, 0.3);

enum HorizAlign { Left, Center, Right }
enum VertAlign { Top, Middle, Bottom }

[Setting hidden]
HorizAlign S_HoverHorizAlign = HorizAlign::Left;

[Setting hidden]
VertAlign S_HoverVertAlign = VertAlign::Bottom;

[Setting hidden]
bool S_HoverManualSize = false;

[Setting hidden]
vec2 S_HoverSize = vec2(300, 180);

[Setting hidden]
bool S_HoverAutoSizeEnableMinimum = true;

[Setting hidden]
vec2 S_HoverAutoSizeMinimumPx = vec2(300, 180);

[Setting hidden]
vec2 S_HoverAutoSizePercent = vec2(30, 30);


void DrawHoverCustomizations() {
    SubHeading("Hover Indicator Position");
    bool orig_S_HoverManualPosition = S_HoverManualPosition;
    bool orig_S_HoverManualSize = S_HoverManualSize;
    auto orig_S_HoverAutoSizeEnableMinimum = S_HoverAutoSizeEnableMinimum;
    auto orig_S_HoverHorizAlign = S_HoverHorizAlign;
    auto orig_S_HoverVertAlign = S_HoverVertAlign;
    auto orig_S_HoverUiUvPosition = S_HoverUiUvPosition;
    auto orig_S_HoverAutoSizePercent = S_HoverAutoSizePercent;
    auto orig_S_HoverAutoSizeMinimumPx = S_HoverAutoSizeMinimumPx;
    auto orig_S_HoverSize = S_HoverSize;

    S_HoverManualPosition = UI::Checkbox("Manually Position?", S_HoverManualPosition);

    /* auto position stuff */

    UI::BeginDisabled(S_HoverManualPosition);
    SubSubHeading("Automatic Positioning Alignment");
    if (UI::BeginCombo("Horizontal Alignment", tostring(S_HoverHorizAlign))) {
        for (uint i = 0; i < 3; i++) {
            if (UI::Selectable(tostring(HorizAlign(i)), i == uint(S_HoverHorizAlign))) {
                S_HoverHorizAlign = HorizAlign(i);
            }
        }
        UI::EndCombo();
    }
    if (UI::BeginCombo("Vertical Alignment", tostring(S_HoverVertAlign))) {
        for (uint i = 0; i < 3; i++) {
            if (UI::Selectable(tostring(VertAlign(i)), i == uint(S_HoverVertAlign))) {
                S_HoverVertAlign = VertAlign(i);
            }
        }
        UI::EndCombo();
    }
    UI::EndDisabled();

    /* manual positioning */

    UI::BeginDisabled(!S_HoverManualPosition);
    SubSubHeading("Manual Positioning");
    VPad(0.25);
    UI::TextWrapped("Note: coordinates are in UI-scaled UVs: top left is (-1, -1) and bottom right is (1, 1).");
    S_HoverUiUvPosition = UI::SliderFloat2("Position", S_HoverUiUvPosition, -1., 1.);

    auto brCorner = hoverAreaPos + hoverAreaSize;
    if (S_HoverManualPosition && !IsWithin(brCorner, uiPosPx, uiSizePx)) {
        UI::TextWrapped("\\$f84Warning! Some part of the hover interface is outside of the Editor UI region! This is bad.");
    }

    UI::EndDisabled();


    SubHeading("Hover Indicator Size");
    S_HoverManualSize = UI::Checkbox("Manually Size?", S_HoverManualSize);

    /* auto sizing */

    UI::BeginDisabled(S_HoverManualSize);

    SubSubHeading("Automatic Sizing");
    S_HoverAutoSizePercent = UI::SliderFloat2("Size as % of UI region", S_HoverAutoSizePercent, 0, 100, "%.1f");
    S_HoverAutoSizeEnableMinimum = UI::Checkbox("Enable Minimum Size?", S_HoverAutoSizeEnableMinimum);
    S_HoverAutoSizeMinimumPx = UI::SliderFloat2("Minimum Size (px)", S_HoverAutoSizeMinimumPx, 10, Math::Min(Draw::GetHeight() / 2., uiSizePx.y));

    UI::EndDisabled();
    /* manual sizing */

    UI::BeginDisabled(!S_HoverManualSize);
    SubSubHeading("Manual Sizing");
    S_HoverSize = UI::SliderFloat2("Size (px)", S_HoverSize, 0, Draw::GetWidth());

    UI::EndDisabled();

    bool changed = false
        || orig_S_HoverManualPosition != S_HoverManualPosition
        || orig_S_HoverManualSize != S_HoverManualSize
        || orig_S_HoverHorizAlign != S_HoverHorizAlign
        || orig_S_HoverVertAlign != S_HoverVertAlign
        || orig_S_HoverAutoSizeEnableMinimum != S_HoverAutoSizeEnableMinimum
        || !Vec2Eq(orig_S_HoverAutoSizePercent, S_HoverAutoSizePercent)
        || !Vec2Eq(orig_S_HoverUiUvPosition, S_HoverUiUvPosition)
        || !Vec2Eq(orig_S_HoverAutoSizeMinimumPx, S_HoverAutoSizeMinimumPx)
        || !Vec2Eq(orig_S_HoverSize, S_HoverSize)
        ;
    if (changed) startnew(OnSettingsChanged);
}


void QuickSetting_Bounds(vec4 bounds, const string &in name, bool addSameLine = true) {
    auto prePos = UI::GetCursorPos();
    auto widthLeft = UI::GetContentRegionMax().x - prePos.x;
    if (UI::Button(name)) S_EditorDrawBounds = bounds;
    if (addSameLine && widthLeft > 400.) UI::SameLine(); // won't wrap if there was less than 300px before drawing first button
}




[Setting hidden]
vec4 S_HoverTextColor = vec4(1, 1, 1, 1);
[Setting hidden]
vec4 S_HoverFillColor = vec4(0.000f, 0.000f, 0.000f, 0.886f);
[Setting hidden]
vec4 S_HoverStrokeColor = vec4(0.780f, 0.780f, 0.780f, 0.325f);
[Setting hidden]
float S_HoverStrokeWidth = 2.;
[Setting hidden]
vec4 S_EditorIndicatorStrokeColor = vec4(0.894f, 0.737f, 0.067f, 0.412f);
[Setting hidden]
float S_EditorIndicatorStrokeWidth = 4.;

[SettingsTab name="Appearance" icon="PaintBrush"]
void S_RenderAppearanceTab() {
    Heading("Hover Indicator");
    S_HoverTextColor = UI::InputColor4("Hover Text Color", S_HoverTextColor);
    S_HoverFillColor = UI::InputColor4("Hover Fill Color", S_HoverFillColor);
    S_HoverStrokeColor = UI::InputColor4("Hover Stroke Color", S_HoverStrokeColor);
    S_HoverStrokeWidth = UI::SliderFloat("Hover Stroke Width", S_HoverStrokeWidth, 0, 5);
    Heading("Editor Indicator");
    S_EditorIndicatorStrokeColor = UI::InputColor4("Editor Outline Stroke Color", S_EditorIndicatorStrokeColor);
    S_EditorIndicatorStrokeWidth = UI::SliderFloat("Editor Outline Stroke Width", S_EditorIndicatorStrokeWidth, 0, 10);
}



[Setting hidden name="Disable Shadows?"]
bool S_LM_DisableShadows = false;

[Setting hidden name="Force Next Item/Block Lowest Lightmap Quality?"]
bool S_LM_ForceLowQuality = false;

[Setting hidden]
bool S_LM_EnableUltra = false;

[Setting hidden]
bool S_LM_SizeMax1k = false;

[SettingsTab name="Lightmap" icon="LightbulbO"]
void S_RenderLightMapTab() {
    Heading("Lighting / Lightmap Options");
    UI::TextWrapped("\\$f84Note: Experimental!\\$z Shouldn't crash your game, but might not actually work...");
    VPad(.5);

    S_LM_DisableShadows = UI::Checkbox("Disable Shadows? " + TTIndicator, S_LM_DisableShadows);
    AddSimpleTooltip("May improve performance wrt block placement and lightmap calculations.");

    S_LM_ForceLowQuality = UI::Checkbox("Force Next Item/Block Lowest Lightmap Quality? " + TTIndicator, S_LM_ForceLowQuality);
    AddSimpleTooltip("May improve performance wrt block placement and lightmap calculations.");

    // doesn't seem to do anything
    // S_BlockComputeShadows = UI::Checkbox("Block calls to ComputeShadows?" + TTIndicator, S_BlockComputeShadows);
    // AddSimpleTooltip("Experimental: calls to CGameEditorPluginMap.ComputeShadows will be blocked.");

    bool orig_S_LM_EnableUltra = S_LM_EnableUltra;
    S_LM_EnableUltra = UI::Checkbox("Unable Ultra Lightmap Generation?" + TTIndicator, S_LM_EnableUltra);
    AddSimpleTooltip("Enables the flag LM_QUltra in display settings.");
    if (orig_S_LM_EnableUltra != S_LM_EnableUltra) {
        Set_LM_QUltra();
    }

    bool orig_S_LM_SizeMax1k = S_LM_SizeMax1k;
    S_LM_SizeMax1k = UI::Checkbox("Set Maximum Lightmap size to 1k^2 (~3x LM Ultra generation speedup)" + TTIndicator, S_LM_SizeMax1k);
    AddSimpleTooltip("Sets LM_SizeMax to `1k^2` (default is `Auto`).");
    if (orig_S_LM_SizeMax1k != S_LM_SizeMax1k) {
        Set_LM_SizeMax();
    }
}

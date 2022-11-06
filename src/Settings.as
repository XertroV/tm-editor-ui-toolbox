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
bool S_HideMapInfo = true;

[Setting hidden]
bool S_ShowBlockLabels = false;

[Setting hidden]
bool S_AlwaysShowEditor = false;

const string TTIndicator = "  \\$888" + Icons::QuestionCircle + "\\$z";


[SettingsTab name="Introduction" icon="Expand"]
void S_RenderIntroTab() {
    RenderIntro();
}


[SettingsTab name="Editor UI 'Scaling'" icon="Expand"]
void S_RenderUIScaleTab() {
    vec4 orig_EditorDrawBounds = vec4(S_EditorDrawBounds);
    bool orig_ShowBlockLabels = S_ShowBlockLabels;

    Heading("Editor UI Options");
    S_AlwaysShowEditor = UI::Checkbox("Always Show Editor UI? \\$f84Unsafe!\\$z" + TTIndicator, S_AlwaysShowEditor);
    AddSimpleTooltip("You will experience phantom UI clicks if you leave this on.\nIt's useful while adjusting the editor UI region, though.");

    S_HideMapInfo = UI::Checkbox("Hide Map Info?" + TTIndicator, S_HideMapInfo);
    AddSimpleTooltip("Hides the green box in the top left that shows map name,\nauthor, coppers cost, and validation status.\n(Sets FrameChallengeParams.IsVisible = false)");
    S_ShowBlockLabels = UI::Checkbox("Show All Block Labels in Inventory?" + TTIndicator, S_ShowBlockLabels);
    AddSimpleTooltip("This will enable labels for the folders / blocks in the inventory.\nThese aren't usually visible.\nTo disable, you might need to restart the editor/game.");

    Heading("Editor UI Quick Settings");
    QuickSetting_Bounds(EditorBounds_FS_Q, "Fullscreen (Standard Editor)");
    QuickSetting_Bounds(EditorBounds_BL_Q, "Bottom Left Quarter (Default)");
    QuickSetting_Bounds(EditorBounds_TL_Q, "Top Left Quarter");
    QuickSetting_Bounds(EditorBounds_TR_Q, "Top Right Quarter");
    QuickSetting_Bounds(EditorBounds_BR_Q, "Bottom Right Quarter");
    QuickSetting_Bounds(EditorBounds_Center_Q, "Center of Screen", false);

    Heading("Editor UI Size/Location");

    VPad(.25);
    UI::TextWrapped("You can set a custom editor UI scale and placement using these sliders.");
    UI::TextWrapped("Note: they are not very intiutive. Use the quick settings buttons above to get a feel. Ctrl + click the sliders to set an exact value.");
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
        OnSettingsChanged();
    }

    if (orig_ShowBlockLabels != S_ShowBlockLabels) {
        g_EditorLabelsDone = false;
    }
}

[Setting hidden]
bool S_HoverIsSimilarlyScaled = true;

[SettingsTab name="Hover Indicator" icon="HandPointerO"]
void S_RenderHoverTab() {
    S_HoverIsSimilarlyScaled = UI::Checkbox("Scale Hover Indicator based on Editor UI Scaling?" + TTIndicator, S_HoverIsSimilarlyScaled);
    AddSimpleTooltip("The hover indicator is similarly scaled to the editor UI.\nIf the editor UI is in the bottom left of the screen,\nthe hover indicator is in the bottom left of the editor UI region.\nIf the editor is 25% of the screen's area and in the center-middle of the screen,\nthen the hover indicator is 25% of the UI's area and in the center-middle of the editor UI region.\nIf the Editor UI is fullscreen, then the hover indicator is also fullscreen.");
    UI::BeginDisabled(S_HoverIsSimilarlyScaled);
    DrawHoverCustomizations();
    UI::EndDisabled();
}

void DrawHoverCustomizations() {
    // todo
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

[SettingsTab name="Lighting / Lightmap" icon="LightbulbO"]
void S_RenderLightMapTab() {
    Heading("Editor UI Options");

    S_LM_DisableShadows = UI::Checkbox("Disable Shadows? " + TTIndicator, S_LM_DisableShadows);
    AddSimpleTooltip("May improve performance wrt block placement and lightmap calculations.");

    S_LM_ForceLowQuality = UI::Checkbox("Force Next Item/Block Lowest Lightmap Quality? " + TTIndicator, S_LM_ForceLowQuality);
    AddSimpleTooltip("May improve performance wrt block placement and lightmap calculations.");


}

namespace EUIScale {
    [Setting hidden]
    bool S_EnableEditorUIScaling = true;

    [Setting hidden]
    bool S_ScaleItemEditorToo = false;

    [Setting hidden]
    bool F_V2ScalingWizardDone = false;

    enum Scalemode {
        Manual,
        Auto_SclPos,
        FixedRes,
    }

    enum UIPos {
        Top_Left,
        Top_Center,
        Top_Right,
        Middle_Left,
        Middle_Center,
        Middle_Right,
        Bottom_Left,
        Bottom_Center,
        Bottom_Right,
    }

    [Setting hidden]
    Scalemode S_V2S_ScaleMode = Scalemode::Auto_SclPos;

    [Setting hidden]
    vec2 S_V2S_ManualUI_Position = vec2(0.0, 0.0);

    [Setting hidden]
    vec2 S_V2S_ManualUI_Scale = vec2(1.0);

    [Setting hidden]
    vec2 S_V2S_FR_Size = vec2(1920, 1080);

    [Setting hidden]
    UIPos S_V2S_FR_Position = UIPos::Bottom_Left;

    // Offset from the position, mostly for fine tuning or if something doesn't work quite right
    [Setting hidden]
    vec2 S_V2S_FR_Offset = vec2(0.0, 0.0);

    [Setting hidden]
    float S_V2S_AutoUI_Scale = .75;

    [Setting hidden]
    UIPos S_V2S_AutoUI_Position = UIPos::Bottom_Left;

    [Setting hidden]
    vec2 S_V2S_AutoUI_OffsetPx = vec2(0.0, 0.0);

    const float aspect16x9 = 16.0 / 9.0;

    // vec2 of coefficients to multiply resolution by to get a 16x9 aspect, shrinked to fit the screen
    vec2 GetAspectCorrection() {
        if (screenAspect > aspect16x9) {
            return vec2(aspect16x9 / screenAspect, 1.0);
        } else {
            return vec2(1.0, screenAspect / aspect16x9);
        }
    }

    vec2 Pixels2UiScale(vec2 sizePx) {
        return sizePx / screenWH;
    }

    vec2 UiScale2Pixels(vec2 sizeUi) {
        return sizeUi * screenWH * GetAspectCorrection();
    }


    void SetUIScale() {
        if (!S_VanillaUIScaleOnly) S_VanillaUIScaleOnly = true;
        try {
            auto editor = cast<CGameCtnEditorFree>(GetApp().Editor);
            if (editor !is null) {
                SetUIScaleOnInterfaceRoot(editor.EditorInterface.InterfaceScene.Mobils[0]);
                return;
            }
        } catch {
            warn("Exception setting UI scale: " + getExceptionInfo());
        }
    }

    void SetUIScaleOnInterfaceRoot(CSceneMobil@ mobil) {
        mobil.SetLocation(GetFrameRootUILocation(), null);
    }

    iso4 GetFrameRootUILocation() {
        switch (S_V2S_ScaleMode) {
            case Scalemode::Manual: return GetManualLocation();
            case Scalemode::Auto_SclPos: return GetAutoLocation();
            case Scalemode::FixedRes: return GetFixedResLocation();
        }
        return iso4();
    }

    iso4 GetManualLocation() {
        return iso4(mat4::Translate(vec3(S_V2S_ManualUI_Position, 0.0)) * mat4::Scale(vec3(S_V2S_ManualUI_Scale, 1.0)));
    }

    const vec2 UiUv_Screen_WH = vec2(3.2, 1.8);

    iso4 GetAutoLocation() {
        // squarify pixels
        vec2 scale = vec2(S_V2S_AutoUI_Scale) * GetAspectCorrection();
        vec2 spaceAroundMidP = (vec2(1.) - scale) * .5 * UiUv_Screen_WH;
        vec2 pos = vec2(0.0);

        switch (S_V2S_AutoUI_Position) {
            case UIPos::Top_Left: pos = spaceAroundMidP; break;
            case UIPos::Top_Center: pos = vec2(0.0, spaceAroundMidP.y); break;
            case UIPos::Top_Right: pos = spaceAroundMidP * vec2(-1., 1.); break;
            case UIPos::Middle_Left: pos = vec2(spaceAroundMidP.x, 0.0); break;
            case UIPos::Middle_Center: pos = vec2(); break;
            case UIPos::Middle_Right: pos = vec2(spaceAroundMidP.x * -1.0, 0.0); break;
            case UIPos::Bottom_Left: pos = spaceAroundMidP * vec2(1., -1.); break;
            case UIPos::Bottom_Center: pos = vec2(0.0, spaceAroundMidP.y * -1.0); break;
            case UIPos::Bottom_Right: pos = spaceAroundMidP * -1.0; break;
        }
        pos += S_V2S_AutoUI_OffsetPx / screenWH * UiUv_Screen_WH * -1.;
        return iso4(mat4::Translate(vec3(pos, 0.0)) * mat4::Scale(vec3(scale, 1.0)));
    }

    iso4 GetFixedResLocation() {
        vec2 scale = Pixels2UiScale(S_V2S_FR_Size);
        vec2 spaceAroundMidP = (vec2(1.) - scale) * .5 * UiUv_Screen_WH;
        vec2 pos = vec2(0.0);

        switch (S_V2S_FR_Position) {
            case UIPos::Top_Left: pos = spaceAroundMidP; break;
            case UIPos::Top_Center: pos = vec2(0.0, spaceAroundMidP.y); break;
            case UIPos::Top_Right: pos = spaceAroundMidP * vec2(-1., 1.); break;
            case UIPos::Middle_Left: pos = vec2(spaceAroundMidP.x, 0.0); break;
            case UIPos::Middle_Center: pos = vec2(); break;
            case UIPos::Middle_Right: pos = vec2(spaceAroundMidP.x * -1.0, 0.0); break;
            case UIPos::Bottom_Left: pos = spaceAroundMidP * vec2(1., -1.); break;
            case UIPos::Bottom_Center: pos = vec2(0.0, spaceAroundMidP.y * -1.0); break;
            case UIPos::Bottom_Right: pos = spaceAroundMidP * -1.0; break;
        }
        pos += S_V2S_FR_Offset / screenWH * UiUv_Screen_WH * -1.;
        return iso4(mat4::Translate(vec3(pos, 0.0)) * mat4::Scale(vec3(scale, 1.0)));
    }


    [Setting hidden]
    bool S_V2S_ShowSliders = true;


    [SettingsTab name="V2 Scaling" icon="ArrowsAlt"]
    void R_V2Scale_Settings() {
        UI::Text("Screen Resolution: " + screenWH.ToString());
        UI::Text("Screen Aspect: " + Text::Format("%.2f", screenAspect));
        UI::Separator();

        UI::PushItemWidth(Math::Max(UI::GetContentRegionAvail().x * .5, 200.0));

        S_EnableEditorUIScaling = UI::Checkbox("Enable Editor UI Scaling (v2)", S_EnableEditorUIScaling);
        S_ScaleItemEditorToo = UI::Checkbox("Also scale Item Editor UI", S_ScaleItemEditorToo);
        if (UI::BeginCombo("Mode", ScaleModeToString(S_V2S_ScaleMode))) {
            if (UI::Selectable(ScaleModeToString(Scalemode::Manual), S_V2S_ScaleMode == Scalemode::Manual)) S_V2S_ScaleMode = Scalemode::Manual;
            if (UI::Selectable(ScaleModeToString(Scalemode::Auto_SclPos), S_V2S_ScaleMode == Scalemode::Auto_SclPos)) S_V2S_ScaleMode = Scalemode::Auto_SclPos;
            if (UI::Selectable(ScaleModeToString(Scalemode::FixedRes), S_V2S_ScaleMode == Scalemode::FixedRes)) S_V2S_ScaleMode = Scalemode::FixedRes;
            UI::EndCombo();
        }
        S_V2S_ShowSliders = UI::Checkbox("Use Sliders for some settings (otherwise text entry)", S_V2S_ShowSliders);

        switch (S_V2S_ScaleMode) {
            case (Scalemode::Manual): DrawManualOpts(); break;
            case (Scalemode::Auto_SclPos): DrawAutoOpts(); break;
            case (Scalemode::FixedRes): DrawFixedResOpts(); break;
            default: UI::Text("Unknown scale mode: " + tostring(S_V2S_ScaleMode));
        }

        UI::PopItemWidth();
    }

    void DrawManualOpts() {
        S_V2S_ManualUI_Position = _InputVec2("Position", S_V2S_ManualUI_Position, -6., 6.0);
        S_V2S_ManualUI_Scale = _InputVec2("Scale", S_V2S_ManualUI_Scale, -2.0, 2.0, clamp: false);
    }

    void DrawAutoOpts() {
        S_V2S_AutoUI_Scale = _InputFloat("Scale", S_V2S_AutoUI_Scale, 0.1, 2.0);
        S_V2S_AutoUI_Position = _InputPosE("Position", S_V2S_AutoUI_Position);
        S_V2S_AutoUI_OffsetPx = UI::InputFloat2("Offset", S_V2S_AutoUI_OffsetPx);
    }

    void DrawFixedResOpts() {
        S_V2S_FR_Size = UI::InputFloat2("Resolution", S_V2S_FR_Size);
        S_V2S_FR_Position = _InputPosE("Position", S_V2S_FR_Position);
        S_V2S_FR_Offset = UI::InputFloat2("Offset", S_V2S_FR_Offset);
    }

    UIPos _InputPosE(const string &in label, UIPos v, const string &in selected = "", int flags = 0) {
        if (UI::BeginCombo(label, selected.Length > 0 ? selected : tostring(v), flags)) {
            for (int i = 0; i < 9; i++) {
                if (UI::Selectable(tostring(UIPos(i)), int(v) == i)) {
                    v = UIPos(i);
                }
            }
            UI::EndCombo();
        }
        return v;
    }

    float _InputFloat(const string &in label, float v, float min, float max, const string &in format = "%.3f", int flags = 0, bool clamp = true) {
        float r;
        if (S_V2S_ShowSliders) {
            r = UI::SliderFloat(label, v, min, max, format, flags);
        } else {
            r = UI::InputFloat(label, v);
            UI::SameLine();
            UI::AlignTextToFramePadding();
            UI::Text("\\$999 (range: " + min + " to " + max + ")");
        }
        if (clamp) {
            r = Math::Clamp(r, min, max);
        }
        return r;
    }

    /// args from min only for sliders
    vec2 _InputVec2(const string &in label, vec2 v, float min, float max, const string &in format = "%.3f", int flags = 0, bool clamp = true) {
        vec2 r;
        if (S_V2S_ShowSliders) {
            r = UI::SliderFloat2(label, v, min, max, format, flags);
        } else {
            r = UI::InputFloat2(label, v);
            UI::SameLine();
            UI::AlignTextToFramePadding();
            UI::Text("\\$999 (range: " + min + " to " + max + ")");
        }
        if (clamp) {
            r.x = Math::Clamp(r.x, min, max);
            r.y = Math::Clamp(r.y, min, max);
        }
        return r;
    }

    string ScaleModeToString(Scalemode mode) {
        switch (mode) {
            case Scalemode::Manual: return "Manual";
            case Scalemode::Auto_SclPos: return "Automatic (Scale + Position)";
            case Scalemode::FixedRes: return "Fixed Resolution";
        }
        return "Unknown";
    }
}

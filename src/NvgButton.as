funcdef void ButtonOnClick(NvgButton@ btn);
funcdef void ButtonOnDrag(NvgButton@ btn);

enum MouseUpdateClick {
    Down, Up, NoChange
}

class NvgButton {
    nvg::Texture@ tex = null;
    int font;
    vec2 pos;
    vec2 size;
    string label;

    private bool isHovered;
    private bool isClicked;
    private bool visible = true;

    ButtonStyle@ style;

    ButtonOnClick@ onClick;
    ButtonOnDrag@ onDrag;

    NvgButton(vec2 &in _pos = vec2(), vec2 &in _size = vec2(50, 50), const string &in _label = Icons::QuestionCircleO, ButtonStyle@ _style = DefaultButtonStyle) {
        font = nvg::LoadFont("DroidSans.ttf");
        pos = _pos;
        size = _size;
        label = _label;
        @style = _style;
    }

    bool UpdateMouse(vec2 mousePos, MouseUpdateClick clickType = MouseUpdateClick::NoChange) {
        if (!IsVisible) return false;
        isHovered = IsWithin(mousePos, pos, size);
        if (clickType == MouseUpdateClick::Down) isClicked = (isHovered && IsVisible);
        if (clickType == MouseUpdateClick::Up) isClicked = false;
        if (isClicked && clickType == MouseUpdateClick::Down && onClick !is null) onClick(this);
        if (isClicked && clickType == MouseUpdateClick::NoChange && onDrag !is null) onDrag(this);
        return isHovered;
    }

    bool get_IsHovered() {
        return isHovered;
    }
    bool get_IsClicked() {
        return isClicked;
    }
    bool get_IsVisible() {
        return visible;
    }
    void set_IsVisible(bool value) {
        visible = value;
    }

    void Draw() {
        if (!visible) return;
        nvg::Reset();
        nvg::BeginPath();
        nvg::Rect(pos, size);
        this.ApplyFill();
        this.ApplyStroke();
        nvg::ClosePath();
        this.DrawText();
    }

    void DrawText() {
        auto fontSize = size.y * 0.9;
        nvg::FontFace(font);
        nvg::FontSize(fontSize);
        nvg::FillColor(style.GetTextColor(isClicked, isHovered));
        nvg::TextAlign(nvg::Align::Center | nvg::Align::Middle);
        auto textBs = nvg::TextBoxBounds(size.x, label);
        auto offset = (size - vec2(size.x, textBs.y - 1.1*fontSize)) / 2.;
        nvg::TextBox(pos + offset, size.x, label);
    }

    void ApplyFill() {
        nvg::FillColor(style.GetFillColor(isClicked, isHovered));
        nvg::Fill();
    }
    void ApplyStroke() {
        auto w = style.GetStrokeWidth(isClicked, isHovered);
        if (1 > 0) {
            nvg::StrokeColor(style.GetStrokeColor(isClicked, isHovered));
            nvg::StrokeWidth(1);
            nvg::Stroke();
        }
    }
}

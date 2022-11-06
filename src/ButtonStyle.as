class ButtonStyle {
    vec4 normalTextColor;
    vec4 hoverTextColor;
    vec4 clickTextColor;

    float normalFontSize;
    float hoverFontSize;
    float clickFontSize;

    vec4 normalFillColor;
    vec4 normalStrokeColor;
    float normalStrokeWidth;

    vec4 hoverFillColor;
    vec4 hoverStrokeColor;
    float hoverStrokeWidth;

    vec4 clickFillColor;
    vec4 clickStrokeColor;
    float clickStrokeWidth;

    ButtonStyle(
        vec4 _textColor = vec4(1, 1, 1, 1), vec4 _hoverTextColor = vec4(1, 1, 1, 1), vec4 _clickTextColor = vec4(1, 1, 1, 1),
        float _fontSize = 40., float _hoverFontSize = 50., float _clickFontSize = 40.,
        vec4 _fillColor = vec4(0, 0, 0, .4), vec4 _strokeColor = vec4(), float _strokeWidth = 0.,
        vec4 _hoverFillColor = vec4(.2, .2, .2, .5), vec4 _hoverStrokeColor = vec4(), float _hoverStrokeWidth = 0.,
        vec4 _clickFillColor = vec4(0, 0, 0, .7), vec4 _clickStrokeColor = vec4(), float _clickStrokeWidth = 0.
    ) {
        normalTextColor = _textColor;
        hoverTextColor = _hoverTextColor;
        clickTextColor = _clickTextColor;

        normalFontSize = _fontSize;
        hoverFontSize = _hoverFontSize;
        clickFontSize = _clickFontSize;

        normalFillColor = _fillColor;
        normalStrokeColor = _strokeColor;
        normalStrokeWidth = _strokeWidth;

        hoverFillColor = _hoverFillColor;
        hoverStrokeColor = _hoverStrokeColor;
        hoverStrokeWidth = _hoverStrokeWidth;

        clickFillColor = _clickFillColor;
        clickStrokeColor = _clickStrokeColor;
        clickStrokeWidth = _clickStrokeWidth;
    }

    vec4 GetFillColor(bool isClicked, bool isHovered) {
        if (isClicked) return clickFillColor;
        if (isHovered) return hoverFillColor;
        return normalFillColor;
    }

    vec4 GetStrokeColor(bool isClicked, bool isHovered) {
        if (isClicked) return clickStrokeColor;
        if (isHovered) return hoverStrokeColor;
        return normalStrokeColor;
    }

    float GetStrokeWidth(bool isClicked, bool isHovered) {
        if (isClicked) return clickStrokeWidth;
        if (isHovered) return hoverStrokeWidth;
        return normalStrokeWidth;
    }

    vec4 GetTextColor(bool isClicked, bool isHovered) {
        if (isClicked) return clickTextColor;
        if (isHovered) return hoverTextColor;
        return normalTextColor;
    }

    float GetFontSize(bool isClicked, bool isHovered) {
        if (isClicked) return clickFontSize;
        if (isHovered) return hoverFontSize;
        return normalFontSize;
    }
}

ButtonStyle@ DefaultButtonStyle = ButtonStyle();

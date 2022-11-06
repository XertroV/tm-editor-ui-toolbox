void Heading(const string &in str) {
    VPad();
    UI::PushFont(uiMontRegularH);
    UI::Text(str);
    UI::PopFont();
    // VPad();
    UI::Separator();
    // VPad();
}

void VPad(float scale = 1.) {
    UI::Dummy(vec2(0, UI::GetTextLineHeight()/2. * scale));
}

void AddSimpleTooltip(const string &in msg) {
    if (!UI::IsItemHovered()) return;
    auto width = Draw::MeasureString(msg).x;
    auto maxWidth = Draw::GetWidth() / 6.;
    UI::BeginTooltip();
    UI::Text(msg);
    // if (width > maxWidth) {
    //     UI::Dummy(vec2(maxWidth, 0));
    //     UI::TextWrapped(msg);
    // } else {
    //     UI::Text(msg);
    // }
    UI::EndTooltip();
}

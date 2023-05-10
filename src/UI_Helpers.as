void Heading(const string &in str) {
    VPad();
    UI::PushFont(uiMontRegularH);
    UI::Text(str);
    UI::PopFont();
    // VPad();
    UI::Separator();
    VPad(.25);
    // VPad();
}

void SubHeading(const string &in str) {
    VPad(.75);
    UI::PushFont(uiMontRegularSH);
    UI::Text(str);
    UI::PopFont();
    // VPad();
    UI::Separator();
    // VPad();
}

void SubSubHeading(const string &in str) {
    VPad(.5);
    UI::PushFont(uiMontRegularSSH);
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
    UI::BeginTooltip();
    UI::Text(msg);
    UI::EndTooltip();
}

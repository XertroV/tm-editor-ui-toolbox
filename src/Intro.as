uint g_IntroSlide = 0;

void RenderIntro() {
    if (g_IntroSlide == 0) RenderSlideZero();
}

string IntroMessage = """
Hello!

V2 Scaling completely changes how things work and it's exactly what you'd expect, now. No caveats.

Additionally, this plugin will let you:
- Hide the Map info in the top left of the UI.
- Show labels for all inventory items / folders (if a label exists).
- Disable some lighting features that might help with large maps / lightmap recalculations. (Suggestion: have the lightmap setting on very low while editing, too.)

Feature requests, bug reports, questions, etc can be directed to \$f19@XertroV\$z on the \$f39Openplanet <3\$z Discord.

GL HF,
XertroV




""";

void RenderSlideZero() {
    Heading("Editor UI Toolbox Intro");
    UI::TextWrapped(IntroMessage);
}

uint g_IntroSlide = 0;

void RenderIntro() {
    if (g_IntroSlide == 0) RenderSlideZero();
}

string IntroMessage = """
Hello!

This plugin will help make the editor UI less intrusive. But it comes with some caveats.
There are also some other useful features.

It will make the UI smaller, but it does not give you more items on screen, etc. It's not native scaling, just a hack.
Other Editor UIs (items, mediatracker, etc) should be unaffected.

When the UI is scaled down, the game registers clicks on UI buttons in two places: where the button\$f84 is\$z on screen, and where the button\$f84 would be\$z on screen at 100% scale.
So, if the editor is small, you could try and place a block on a blank part of the screen and the UI thinks you selected a different block. That sort of thing can happen.

For this reason, we need to hide the UI when we don't want to accidentally click stuff (i.e., the mouse is outside the region that the editor UI is scaled to).
Hiding the UI prevents these 'misclicks'. It's safer to place blocks outside the editor UI's region (if it's showing).

So, this is how the plugin works:
1. You set a region of the screen to remap the editor UI to (default: bottom left quarter).
2. The editor is hidden by default, so you need to hover a (smaller) region of the screen to activate the editor UI. It will then become visible.
3. Use the UI like normal, select blocks, etc.
4. Move the cursor outside the UI bounds (indicated) to hide the editor again.
5. Place blocks.
6. Hover the indicated region again to show the UI, select new blocks, etc.

The size and location of the UI is compeltely configurable, as is the size/location of the hover indicator (with the caveat that the hover indicator must be within the UI region).

Additionally, this plugin will let you:
- Hide the Map info in the top left of the UI.
- Show labels for all inventory items / folders (if a label exists).
- Auto-hide the inventory (just like if you pressed tab).
- Disable some lighting features that might help with large maps / lightmap recalculations. (Suggestion: have the lightmap setting on very low while editing, too.)

I hope you find this plugin useful.

Feature requests, bug reports, questions, etc can be directed to \$f19@XertroV\$z on the \$f39Openplanet <3\$z Discord.

GL HF,
XertroV




""";

void RenderSlideZero() {
    Heading("Editor UI Toolbox Intro");
    UI::TextWrapped(IntroMessage);
}

uint g_IntroSlide = 0;

void RenderIntro() {
    if (g_IntroSlide == 0) RenderSlideZero();
}

void RenderSlideZero() {
    Heading("Rescale Editor UI Intro");
    UI::TextWrapped("""
Hello!

This plugin will help make the editor UI less intrusive. But it comes with some caveats.
There are also some other useful features.

It will make the UI smaller, but it does not give you more items on screen, etc. It's not native scaling, just a hack.

When the UI is scaled down, the game registers clicks on UI buttons in two places: where the button\$ff8 is\$z on screen, and where the button\$ff8 would be\$z on screen at 100% scale.
So, if the editor is small, you could try and place a block on a blank part of the screen and the UI thinks you selected a different block. That sort of thing can happen.

For this reason, we need to hide the UI when we don't want to accidentally click stuff (i.e., the mouse is outside the region that the editor UI is scaled to).
Hiding the UI prevents these 'misclicks'.

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
- Disable some lighting features that might help with large maps / lightmap recalculations. (Suggestion: have the lightmap setting on very low while editing, too.)

I hope you find this plugin useful.

Feature requests, bug reports, questions, etc can be directed to @XertroV on the Openplanet Discord.

GL HF,
XertroV






    """);
}

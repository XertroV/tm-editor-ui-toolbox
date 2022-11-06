void DrawDebugAutoHideInventory() {
    nvg::Reset();
    nvg::BeginPath();
    nvg::Rect(inventoryAreaPos, inventoryAreaSize);
    nvg::FillColor(vec4(1, .1, .5, .5));
    nvg::Fill();
    nvg::ClosePath();
}

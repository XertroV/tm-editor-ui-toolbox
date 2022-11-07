// doesn't seem to block anything

#if FALSE

[Setting hidden]
bool S_BlockComputeShadows = false;

bool m_computeShadowsItercepted = false;
void WatchComputeShadowsIntercept() {
    while (true) {
        yield();
        if (S_BlockComputeShadows && !m_computeShadowsItercepted) {
            m_computeShadowsItercepted = true;
            // Dev::InterceptProc("CGameEditorPluginMap", "ComputeShadows", _ComputeShadows);
            Dev::InterceptProc("CGameEditorPluginMap", "ComputeShadows1", _ComputeShadows);
            trace("Compute Shadows intercept enabled.");
        } else if (!S_BlockComputeShadows && m_computeShadowsItercepted) {
            m_computeShadowsItercepted = false;
            // Dev::ResetInterceptProc("CGameEditorPluginMap", "ComputeShadows", _ComputeShadows);
            Dev::ResetInterceptProc("CGameEditorPluginMap", "ComputeShadows1", _ComputeShadows);
            trace("Compute Shadows intercept disabled.");
        }
    }
}

bool _ComputeShadows(CMwStack &in stack, CMwNod@ nod) {
    trace('compute shadows intercepted');
    if (stack.Count() > 0) {
        auto sq = CGameEditorPluginMap::EShadowsQuality(stack.CurrentEnum());
        print('compute shadows quality: ' + tostring(sq));
    }
    return true;
}

#endif

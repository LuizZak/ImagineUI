/// Provides a `Renderer` that is coupled to an `Image` backing which can be
/// consumed after all draw operations have finished.
public protocol ImageRenderContext {
    /// Performs rendering isolated within a block, returning the produced image
    /// at the end.
    func withRenderer(_ block: (Renderer) -> Void) -> Image
}

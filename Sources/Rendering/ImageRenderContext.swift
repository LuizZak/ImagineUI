/// Provides a `Renderer` that is coupled to an `Image` backing which can be
/// consumed after all draw operations have finished.
public protocol ImageRenderContext {
    /// The backing renderer to draw on the image
    var renderer: Renderer { get }
    
    /// Flushes all operations made on the renderer and produce an image.
    /// May not be called more than once.
    func renderedImage() -> Image
}

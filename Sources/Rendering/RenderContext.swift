import RenderingCommon

/// A context for one or more `Renderer`s that can be used to create images and
/// resources that are usable by any `Renderer` instance of the same context.
public protocol RenderContext {
    /// Gets the font manager object
    var fontManager: FontManager { get }

    /// Creates an empty image with the given dimensions.
    /// The pixels of the image are pre-filled with (alpha: 0, red: 0, green: 0, blue: 0).
    func createImage(width: Int, height: Int) -> Image

    /// Creates an empty image renderer context with the given dimensions.
    /// The pixels of the image are pre-filled with (alpha: 0, red: 0, green: 0, blue: 0).
    func createImageRenderer(width: Int, height: Int) -> ImageRenderContext
}

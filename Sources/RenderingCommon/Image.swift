import Geometry

/// Protocol that represents images created by a `RendererContext`
public protocol Image {
    var size: UIIntSize { get }

    /// Returns `true` if this image is pixel-matched to `other`.
    func pixelEquals(to other: Image) -> Bool

    /// Returns `true` if this image instance references the same underlying
    /// bitmap as `other`.
    func instanceEquals(to other: Image) -> Bool
}

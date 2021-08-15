/// Protocol that represents images created by a `RendererContext`
public protocol Image {
    var width: Int { get }
    var height: Int { get }
    
    /// Returns `true` if this image is pixel-matched to another image
    func pixelEquals(to other: Image) -> Bool
}

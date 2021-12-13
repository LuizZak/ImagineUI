import SwiftBlend2D
import Geometry
import Rendering

/// Wraps a BLImage for rendering.
public class Blend2DImage: Image {
    var image: BLImage

    public var size: UIIntSize {
        .init(width: image.width, height: image.height)
    }

    public init(image: BLImage) {
        self.image = image
    }

    public func pixelEquals(to other: Image) -> Bool {
        guard let other = other as? Blend2DImage else {
            return false
        }

        return image == other.image
    }

    public func instanceEquals(to other: Image) -> Bool {
        guard let other = other as? Blend2DImage else {
            return false
        }

        return image === other.image
    }
}

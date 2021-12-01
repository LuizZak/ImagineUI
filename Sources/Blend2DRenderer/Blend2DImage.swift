import SwiftBlend2D
import Geometry
import Rendering

class Blend2DImage: Image {
    var image: BLImage

    var size: UIIntSize {
        .init(width: image.width, height: image.height)
    }

    init(image: BLImage) {
        self.image = image
    }

    func pixelEquals(to other: Image) -> Bool {
        guard let other = other as? Blend2DImage else {
            return false
        }

        return image == other.image
    }

    func instanceEquals(to other: Image) -> Bool {
        guard let other = other as? Blend2DImage else {
            return false
        }

        return image === other.image
    }
}

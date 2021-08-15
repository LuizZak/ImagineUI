import SwiftBlend2D
import Rendering

class Blend2DImage: Image {
    var image: BLImage
    
    var width: Int { image.width }
    var height: Int { image.height }
    
    init(image: BLImage) {
        self.image = image
    }
    
    func pixelEquals(to other: Image) -> Bool {
        guard let other = other as? Blend2DImage else {
            fatalError("Unexpected image type \(type(of: other))")
        }
        
        return image == other.image
    }
}

import Geometry
import Rendering

/// A view which renders a bitmap image within its bounds
public class ImageView: View {
    public var image: Image? {
        didSet {
            if image == nil && oldValue == nil { return }
            if let old = oldValue, image?.pixelEquals(to: old) == true { return }
            
            setNeedsLayout()
            invalidate()
        }
    }
    
    public override var intrinsicSize: Size? {
        if let image = image {
            return Size(x: Double(image.width), y: Double(image.height))
        }
        
        return nil
    }
    
    public init(image: Image?) {
        self.image = image
        
        super.init()
    }
    
    public override func render(in renderer: Renderer, screenRegion: ClipRegion) {
        super.render(in: renderer, screenRegion: screenRegion)

        if let image = image {
            renderer.drawImage(image, at: .zero)
        }
    }
}

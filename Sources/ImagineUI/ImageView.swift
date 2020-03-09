import SwiftBlend2D

/// A view which renders a bitmap image within its bounds
public class ImageView: View {
    public var image: BLImage? {
        didSet {
            if image == oldValue { return }
            
            setNeedsLayout()
            invalidate()
        }
    }
    
    public override var intrinsicSize: Size? {
        if let image = image {
            return Size(x: Double(image.size.w), y: Double(image.size.h))
        }
        
        return nil
    }
    
    public init(image: BLImage?) {
        self.image = image
        
        super.init()
    }
    
    public override func render(in context: BLContext, screenRegion: BLRegion) {
        super.render(in: context, screenRegion: screenRegion)

        if let image = image {
            context.blitImage(image, at: BLPoint.zero)
        }
    }
}

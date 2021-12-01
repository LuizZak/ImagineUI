import Geometry
import Rendering

/// A view which renders a bitmap image within its bounds
public class ImageView: View {
    public var image: Image? {
        didSet {
            if image == nil && oldValue == nil { return }
            if let old = oldValue, image?.instanceEquals(to: old) == true { return }

            if oldValue?.size != image?.size {
                setNeedsLayout()
            }

            invalidate()
        }
    }

    public override var intrinsicSize: UISize? {
        if let image = image {
            return UISize(image.size)
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

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

    /// The scaling mode to use when rendering an image that has a different size
    /// to the image view's bounds.
    ///
    /// Defaults to '.topLeftAsIs'.
    public var scalingMode: ImageScale = .topLeftAsIs

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

    public override func render(in renderer: Renderer, screenRegion: ClipRegionType) {
        super.render(in: renderer, screenRegion: screenRegion)

        guard let image = image else {
            return
        }

        switch scalingMode {
        case .topLeftAsIs:
            renderer.drawImage(image, at: .zero)

        default:
            let imageRect = scalingMode.apply(container: bounds, imageSize: UISize(image.size))
            renderer.drawImageScaled(image, area: imageRect)
        }
    }

    /// Indicates the image scaling strategy to use when rendering an image that
    /// has a different size to the image view that contains it.
    public enum ImageScale {
        /// Renders the image on the top-left of the boundaries.
        case topLeftAsIs

        /// Moves the center of the image to the center of the render bounds
        /// before rendering.
        case centeredAsIs

        /// Stretches the image so it fits the bounding box exactly.
        case stretch

        /// Scales the image, maintaining the original aspect ratio.
        case aspectFit

        /// Applies this image scaling to a container rectangle and image size,
        /// returning the rectangle that represents the target location and size
        /// of the image according to this `ImageScale` value.
        internal func apply(container: UIRectangle, imageSize: UISize) -> UIRectangle {
            var imageRectangle = UIRectangle(location: .zero, size: imageSize)

            switch self {
            case .topLeftAsIs:
                return imageRectangle.withLocation(container.location)

            case .centeredAsIs:
                return imageRectangle.movingCenter(to: container.center)

            case .stretch:
                return container

            case .aspectFit:
                let size2 = imageSize;
                let num = container.width / size2.width;
                let num2 = container.height / size2.height;

                if size2.width <= container.width && size2.height <= container.height {
                    return UIRectangle(
                        x: container.width / 2 - size2.width / 2,
                        y: container.height / 2 - size2.height / 2,
                        width: size2.width,
                        height: size2.height
                    )
                }

                if num >= num2 {
                    imageRectangle.height = container.height
                    imageRectangle.width = (size2.width * num2) + 0.5

                    if container.x >= 0 {
                        imageRectangle.x = (container.width - imageRectangle.width) / 2
                    }
                } else {
                    imageRectangle.width = container.width
                    imageRectangle.height = (size2.height * num) + 0.5

                    if container.y >= 0 {
                        imageRectangle.y = (container.height - imageRectangle.height) / 2
                    }
                }

                return imageRectangle
            }
        }
    }
}

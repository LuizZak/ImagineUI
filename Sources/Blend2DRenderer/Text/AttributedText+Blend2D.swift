import SwiftBlend2D
import Text
import Rendering

// MARK: - Rendering
extension AttributedText {
    /// Renders this attributed text to a given context.
    ///
    /// - Parameter context: The context to render the text to.
    /// - Parameter origin: The top-left origin of the text in respect to the
    /// context.
    /// - Parameter baseFont: The base font to use when a text segment specifies
    /// no font attribute. Does not override fonts specified by attributes.
    /// - Parameter horizontalAlignment: Horizontal alignment of the text layout.
    /// - Parameter verticalAlignment: Vertical alignment of the text layout.
    func render(
        to context: BLContext,
        origin: BLPoint,
        baseFont: BLFont,
        horizontalAlignment: HorizontalTextAlignment = .leading,
        verticalAlignment: VerticalTextAlignment = .near
    ) {

        let layout = TextLayout(
            font: Blend2DFont(font: baseFont),
            attributedText: self,
            horizontalAlignment: horizontalAlignment,
            verticalAlignment: verticalAlignment
        )

        let renderer = TextLayoutRenderer(textLayout: layout)

        renderer.render(in: context, location: origin)
    }
}

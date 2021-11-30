public extension UIRectangle {
    /// Returns a new UIRectangle that matches this rectangle's size, while changing
    /// its horizontal location to match the horizontal position of another rectangle
    /// with a specified alignment.
    func alignHorizontally(to rectangle: UIRectangle, alignment: UIAlignment) -> UIRectangle {
        switch alignment {
        case .leading:
            return movingLeft(to: rectangle.left)

        case .center:
            return movingCenterX(to: rectangle.centerX)

        case .trailing:
            return movingRight(to: rectangle.right)
        }
    }

    /// Returns a new UIRectangle that matches this rectangle's size, while changing
    /// its vertical location to match the vertical position of another rectangle
    /// with a specified alignment.
    func alignVertically(to rectangle: UIRectangle, alignment: UIAlignment) -> UIRectangle {
        switch alignment {
        case .leading:
            return movingTop(to: rectangle.top)

        case .center:
            return movingCenterY(to: rectangle.centerY)

        case .trailing:
            return movingBottom(to: rectangle.bottom)
        }
    }

    /// Returns a new UIRectangle that matches this rectangle's size, while changing
    /// its location to match its right edge to another rectangle's left edge,
    /// with a specified vertical alignment.
    func alignLeft(of rectangle: UIRectangle, spacing: Double = 0.0, verticalAlignment: UIAlignment = .leading) -> UIRectangle {
        movingRight(to: rectangle.left - spacing)
            .alignVertically(to: rectangle, alignment: verticalAlignment)
    }

    /// Returns a new UIRectangle that matches this rectangle's size, while changing
    /// its location to match its left edge to another rectangle's right edge,
    /// with a specified vertical alignment.
    func alignRight(of rectangle: UIRectangle, spacing: Double = 0.0, verticalAlignment: UIAlignment = .leading) -> UIRectangle {
        movingLeft(to: rectangle.right + spacing)
            .alignVertically(to: rectangle, alignment: verticalAlignment)
    }

    /// Returns a new UIRectangle that matches this rectangle's size, while changing
    /// its location to match its bottom edge to another rectangle's top edge,
    /// with a specified horizontal alignment.
    func alignTop(of rectangle: UIRectangle, spacing: Double = 0.0, horizontalAlignment: UIAlignment = .leading) -> UIRectangle {
        movingBottom(to: rectangle.top - spacing)
            .alignHorizontally(to: rectangle, alignment: horizontalAlignment)
    }

    /// Returns a new UIRectangle that matches this rectangle's size, while changing
    /// its location to match its top edge to another rectangle's bottom edge,
    /// with a specified horizontal alignment.
    func alignBottom(of rectangle: UIRectangle, spacing: Double = 0.0, horizontalAlignment: UIAlignment = .leading) -> UIRectangle {
        movingTop(to: rectangle.bottom + spacing)
            .alignHorizontally(to: rectangle, alignment: horizontalAlignment)
    }
}

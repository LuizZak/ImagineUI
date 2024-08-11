/// Represents a 4-component ARGB color
public struct Color: Hashable, Codable {
    @Clamped(min: 0, max: 255)
    public var alpha: Int = 0

    @Clamped(min: 0, max: 255)
    public var red: Int = 0

    @Clamped(min: 0, max: 255)
    public var green: Int = 0

    @Clamped(min: 0, max: 255)
    public var blue: Int = 0

    /// Packs this color value as a 32-bit integer alpha-red-green-blue ordered
    /// color value.
    public var asARGB: Int {
        let alpha = alpha << 24
        let red = red << 16
        let green = green << 8
        let blue = blue

        return alpha | red | green | blue
    }

    /// Packs this color value as a 32-bit integer red-green-blue-alpha ordered
    /// color value.
    public var asRGBA: Int {
        let red = red << 24
        let green = green << 16
        let blue = blue << 8
        let alpha = alpha

        return red | green | blue | alpha
    }

    /// Decodes an ARGB color from a given decoder.
    public init(from decoder: any Decoder) throws {
        var container = try decoder.unkeyedContainer()

        let alpha = try container.decode(Int.self)
        let red = try container.decode(Int.self)
        let green = try container.decode(Int.self)
        let blue = try container.decode(Int.self)

        self.init(alpha: alpha, red: red, green: green, blue: blue)
    }

    /// Initializes a new color with the given RGB + alpha components.
    public init(alpha: Int = 255, red: Int, green: Int, blue: Int) {
        self.alpha = alpha
        self.red = red
        self.green = green
        self.blue = blue
    }

    /// Encodes an ARGB color into a given encoder.
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.unkeyedContainer()

        try container.encode(alpha)
        try container.encode(red)
        try container.encode(green)
        try container.encode(blue)
    }

    /// Returns a copy of this color with a given alpha attributed to it.
    public func withTransparency(_ alpha: Int) -> Color {
        return Color(alpha: alpha, red: red, green: green, blue: blue)
    }

    /// Returns a copy of this color with the alpha component set to `255 * factor`.
    public func withTransparency(factor: Double) -> Color {
        return Color(
            alpha: Int(255 * factor),
            red: red,
            green: green,
            blue: blue
        )
    }

    /// Fades each component of this color towards a given color by a factor of
    /// `factor`, optionally fading also the alpha component.
    ///
    /// A factor of `0` returns `self`, and a factor of `1` returns `otherColor`,
    /// with alpha unchanged depending on `blendAlpha`.
    public func faded(
        towards otherColor: Color,
        factor: Double,
        blendAlpha: Bool = false
    ) -> Color {
        let from = 1 - factor

        let a = blendAlpha ? Double(self.alpha) * from + Double(otherColor.alpha) * factor : Double(self.alpha)
        let r = Double(self.red) * from + Double(otherColor.red) * factor
        let g = Double(self.green) * from + Double(otherColor.green) * factor
        let b = Double(self.blue) * from + Double(otherColor.blue) * factor

        return Color(alpha: Int(a), red: Int(r), green: Int(g), blue: Int(b))
    }

    /// Flattens this color and a given fore color by their alpha components,
    /// with `self` obscured by `foreColor` depending on their alpha components.
    ///
    /// The behavior of the flattening is similar to GDI+'s color blending operations.
    public func flattened(withForeColor foreColor: Color) -> Color {
        Self.flatten(self, withColor: foreColor)
    }

    /// Flattens a pair of colors by their alpha components, with `backColor`
    /// obscured by `foreColor` depending on their alpha components.
    ///
    /// The behavior of the flattening is similar to GDI+'s color blending operations.
    static func flatten(_ backColor: Color, withColor foreColor: Color) -> Color {
        // Based off an answer by an anonymous user on StackOverflow http://stackoverflow.com/questions/1718825/blend-formula-for-gdi/2223241#2223241
        let backR: Double = Double(backColor.red),
            backG: Double = Double(backColor.green),
            backB: Double = Double(backColor.blue),
            backA: Double = Double(backColor.alpha)

        let foreR: Double = Double(foreColor.red),
            foreG: Double = Double(foreColor.green),
            foreB: Double = Double(foreColor.blue),
            foreA: Double = Double(foreColor.alpha)

        if foreA == 0 {
            return backColor
        }
        if foreA == 1 {
            return foreColor
        }

        let backAlphaFloat = backA
        let foreAlphaFloat = foreA

        let foreAlphaNormalized = foreAlphaFloat / 255.0
        let backColorMultiplier = backAlphaFloat * (1 - foreAlphaNormalized)

        let alpha = backAlphaFloat + foreAlphaFloat - backAlphaFloat * foreAlphaNormalized

        return Color(
            alpha: alpha,
            red: min(1, (foreR * foreAlphaFloat + backR * backColorMultiplier) / alpha),
            green: min(1, (foreG * foreAlphaFloat + backG * backColorMultiplier) / alpha),
            blue: min(1, (foreB * foreAlphaFloat + backB * backColorMultiplier) / alpha)
        )
    }
}

public extension Color {
    /// Returns whether this color instance is fully transparent (alpha = 0)
    var isTransparent: Bool {
        return alpha == 0
    }
}

// MARK: Alternative initializers

public extension Color {
    /// Initializes a new color using floating-point components, clamped to be
    /// between (0, 1).
    init(
        alpha: Double,
        red: Double,
        green: Double,
        blue: Double
    ) {
        self.init(
            alpha: Int(alpha * 255),
            red: Int(red * 255),
            green: Int(green * 255),
            blue: Int(blue * 255)
        )
    }

    /// Initializes a new color using a floating-point HSB (hue-saturation-brightness)
    /// values with an alpha component.
    init(
        alpha: Double = 1.0,
        hue: Double,
        saturation: Double,
        brightness: Double
    ) {
        var hue = hue

        var red: Double
        var green: Double
        var blue: Double
        if saturation == 0.0 {
            red   = brightness
            green = brightness
            blue  = brightness
        } else {
            if hue == 360 {
                hue = 0
            }
            let slice: Int = Int(hue) / 60
            let hf: Double = hue / 60 - Double(slice)
            let aa: Double = brightness * (1 - saturation)
            let bb: Double = brightness * (1 - saturation * hf)
            let cc: Double = brightness * (1 - saturation * (1.0 - hf))

            switch slice {
                case 0: red = brightness; green = cc;   blue = aa;  break
                case 1: red = bb;  green = brightness;  blue = aa;  break
                case 2: red = aa;  green = brightness;  blue = cc;  break
                case 3: red = aa;  green = bb;   blue = brightness; break
                case 4: red = cc;  green = aa;   blue = brightness; break
                case 5: red = brightness; green = aa;   blue = bb;  break
                default: red = 0;  green = 0;    blue = 0;   break
            }
        }

        self.init(alpha: alpha > 1 ? 1 : alpha, red: red, green: green, blue: blue)
    }

    /// Initializes a new color using 0-255 (0-360 for Hue) HSB (hue-saturation-brightness)
    /// values with an alpha component.
    init(
        alpha: Int = 255,
        hue: Int,
        saturation: Int,
        brightness: Int
    ) {
        self.init(
            alpha: Double(alpha / 255),
            hue: Double(hue),
            saturation: Double(saturation / 255),
            brightness: Double(brightness / 255)
        )
    }

    /// Initializes a new color using a packed 32-bit ARGB color value.
    init(argb: Int) {
        let alpha = argb >> 24 & 0xff
        let red = argb >> 16 & 0xff
        let green = argb >> 8 & 0xff
        let blue = argb & 0xff

        self.init(
            alpha: alpha,
            red: red,
            green: green,
            blue: blue
        )
    }

    /// Initializes a new color using a packed 32-bit ARGB color value.
    init(argb: UInt32) {
        self.init(argb: Int(argb))
    }

    /// Initializes a new color using a packed 32-bit RGBA color value.
    init(rgba: Int) {
        let red = rgba >> 24 & 0xff
        let green = rgba >> 16 & 0xff
        let blue = rgba >> 8 & 0xff
        let alpha = rgba & 0xff

        self.init(
            alpha: alpha,
            red: red,
            green: green,
            blue: blue
        )
    }

    /// Initializes a new color using a packed 32-bit RGBA color value.
    init(rgba: UInt32) {
        self.init(rgba: Int(rgba))
    }
}

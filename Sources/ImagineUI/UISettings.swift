import Geometry
import Rendering

/// General UI settings that affects all views and controls
public enum UISettings {
    /// Represents the internal configuration state of the UI settings object,
    /// set with `UISettings.initialize`
    internal static var configuration: Configuration?
    
    /// The global render context for the UI system
    public static var globalRenderContext: RenderContext?
    
    /// Rendering scale for UI.
    /// Affects scaling of caches of views in bitmap format.
    public static var scale: UIVector = UIVector(x: 2, y: 2)
    
    /// Attempts to get the global render context of the UI system.
    /// Throws a runtime error if `globalRenderContext` is `nil`
    public static func tryGetRenderContext() -> RenderContext {
        if let renderContext = globalRenderContext {
            return renderContext
        }
        
        fatalError("UISettings.globalRenderContext must be set prior to using UISettings.tryGetRenderContext()")
    }
    
    public static func initialize(_ config: Configuration) throws {
        self.configuration = config
        
        try Fonts.configure(fontManager: config.fontManager,
                            defaultFontPath: config.defaultFontPath)
    }
    
    public struct Configuration {
        public var fontManager: FontManager
        public var defaultFontPath: String
        
        public init(fontManager: FontManager, defaultFontPath: String) {
            self.fontManager = fontManager
            self.defaultFontPath = defaultFontPath
        }
    }
}

internal extension UISettings {
    /// Attempts to retrieve `UISettings.configuration`, or crashes the application,
    /// in case the UI is not properly configured.
    static func configurationOrFatal() -> Configuration {
        if let config = configuration {
            return config
        }
        
        fatalError("UISettings.initialize(_:) was not called prior to using ImagineUI's API")
    }
}

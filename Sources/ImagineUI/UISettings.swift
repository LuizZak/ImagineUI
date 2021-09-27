import Foundation
import Geometry
import Rendering

/// Type for UISettings.timeInSeconds
public typealias TimeInSecondsFunction = () -> TimeInterval

/// General UI settings that affects all views and controls
public enum UISettings {
    /// Represents the internal configuration state of the UI settings object,
    /// set with `UISettings.initialize`
    internal static var configuration: Configuration?
    
    /// The global render context for the UI system
    public static var globalRenderContext: RenderContext?

    /// OS-specific method that returns the current time in seconds.
    /// Time's starting value is not defined, but it must increase in steps of
    /// 1.0 per 1 second of execution time.
    public static var timeInSeconds: TimeInSecondsFunction = {
        fatalError("UISettings.initialize() must be called prior to using UISettings.timeInSeconds()")
    }
    
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
        
        self.timeInSeconds = config.timeInSecondsFunction
        
        try Fonts.configure(
            fontManager: config.fontManager,
            defaultFontPath: config.defaultFontPath
        )
    }
    
    public struct Configuration {
        public var fontManager: FontManager
        public var defaultFontPath: String
        public var timeInSecondsFunction: TimeInSecondsFunction
        
        public init(fontManager: FontManager, 
                    defaultFontPath: String,
                    timeInSecondsFunction: @escaping TimeInSecondsFunction) {
            
            self.fontManager = fontManager
            self.defaultFontPath = defaultFontPath
            self.timeInSecondsFunction = timeInSecondsFunction
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

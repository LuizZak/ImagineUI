/// Provides a common logging interface API for ImagineUI components.
///
/// Mostly useful during development to report messages from within the ImagineUI
/// runtime to an external logger type.
public enum ImagineUILogger {
    public static var logger: ImagineUILoggerType?

    public static func info(
        _ message: @autoclosure () -> CustomStringConvertible,
        file: String = #fileID,
        function: String = #function,
        line: UInt = #line
    ) {
        logger?.info(
            message().description,
            file: file,
            function: function,
            line: line
        )
    }

    public static func warning(
        _ message: @autoclosure () -> CustomStringConvertible,
        file: String = #fileID,
        function: String = #function,
        line: UInt = #line
    ) {
        logger?.warning(
            message().description,
            file: file,
            function: function,
            line: line
        )
    }

    public static func error(
        _ message: @autoclosure () -> CustomStringConvertible,
        file: String = #fileID,
        function: String = #function,
        line: UInt = #line
    ) {
        logger?.error(
            message().description,
            file: file,
            function: function,
            line: line
        )
    }

    public static func critical(
        _ message: @autoclosure () -> CustomStringConvertible,
        file: String = #fileID,
        function: String = #function,
        line: UInt = #line
    ) {
        logger?.critical(
            message().description,
            file: file,
            function: function,
            line: line
        )
    }
}

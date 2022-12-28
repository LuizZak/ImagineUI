/// A type that provides logging functionality.
public protocol ImagineUILoggerType {
    func info(
        _ message: @autoclosure () -> String,
        file: String,
        function: String,
        line: UInt
    )

    func warning(
        _ message: @autoclosure () -> String,
        file: String,
        function: String,
        line: UInt
    )

    func error(
        _ message: @autoclosure () -> String,
        file: String,
        function: String,
        line: UInt
    )

    func critical(
        _ message: @autoclosure () -> String,
        file: String,
        function: String,
        line: UInt
    )
}

public extension ImagineUILoggerType {
    func info(
        _ message: @autoclosure () -> String,
        file: String = #fileID,
        function: String = #function,
        line: UInt = #line
    ) {
        self.info(
            message(),
            file: file,
            function: function,
            line: line
        )
    }

    func warning(
        _ message: @autoclosure () -> String,
        file: String = #fileID,
        function: String = #function,
        line: UInt = #line
    ) {
        self.warning(
            message(),
            file: file,
            function: function,
            line: line
        )
    }

    func error(
        _ message: @autoclosure () -> String,
        file: String = #fileID,
        function: String = #function,
        line: UInt = #line
    ) {
        self.error(
            message(),
            file: file,
            function: function,
            line: line
        )
    }

    func critical(
        _ message: @autoclosure () -> String,
        file: String = #fileID,
        function: String = #function,
        line: UInt = #line
    ) {
        self.critical(
            message(),
            file: file,
            function: function,
            line: line
        )
    }
}

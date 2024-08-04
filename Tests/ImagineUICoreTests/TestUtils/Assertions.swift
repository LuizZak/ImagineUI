import XCTest

/// Asserts that two collection of items contains the same set of `T` values the
/// same number of times.
public func assertEqualUnordered<T>(
    _ lhs: some Collection<T>,
    _ rhs: some Collection<T>,
    compare: (T, T) -> Bool,
    message: @autoclosure () -> String = "",
    file: StaticString = #file,
    line: UInt = #line
) {

    if lhs.count != rhs.count {
        XCTFail(
            "\(message()) lhs.count != rhs.count (\(lhs.count) != \(rhs.count)) lhs: \(lhs) rhs: \(rhs)".trimmingCharacters(in: .whitespaces),
            file: file,
            line: line
        )
        return
    }

    let signal: (String) -> Void = {
        XCTFail(
            "\($0) lhs != rhs (\(lhs) != \(rhs))".trimmingCharacters(in: .whitespaces),
            file: file,
            line: line
        )
    }

    var remaining = Array(lhs)
    for item in rhs {
        if let nextIndex = remaining.firstIndex(where: { compare($0, item) }) {
            remaining.remove(at: nextIndex)
        } else {
            return signal("Found unmatched rhs element \(item) \(message())")
        }
    }

    if !remaining.isEmpty {
        signal("Found unmatched lhs elements \(remaining) \(message())")
    }
}


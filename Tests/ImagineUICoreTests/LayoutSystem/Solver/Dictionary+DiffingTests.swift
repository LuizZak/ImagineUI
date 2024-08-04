import XCTest

@testable import ImagineUICore

class Dictionary_DiffingTests: XCTestCase {
    typealias Sut = [Int: String]

    func testMakeDifference_fromEmpty() {
        let prev: Sut = [:]
        let next: Sut = [
            0: "1",
            1: "2",
        ]

        next.assertDiffEquals(
            previous: prev,
            expectedAdded: [(0, "1"), (1, "2")],
            expectedUpdated: [],
            expectedRemoved: []
        )
    }

    func testMakeDifference_toEmpty() {
        let prev: Sut = [
            0: "1",
            1: "2",
        ]
        let next: Sut = [:]

        next.assertDiffEquals(
            previous: prev,
            expectedAdded: [],
            expectedUpdated: [],
            expectedRemoved: [(0, "1"), (1, "2")]
        )
    }

    func testMakeDifference_updatedValue() {
        let prev: Sut = [
            0: "1",
        ]
        let next: Sut = [
            0: "2",
        ]

        next.assertDiffEquals(
            previous: prev,
            expectedAdded: [],
            expectedUpdated: [(0, "1", "2")],
            expectedRemoved: []
        )
    }

    func testMakeDifference_updatedKey() {
        let prev: Sut = [
            0: "1",
        ]
        let next: Sut = [
            1: "1",
        ]

        next.assertDiffEquals(
            previous: prev,
            expectedAdded: [(1, "1")],
            expectedUpdated: [],
            expectedRemoved: [(0, "1")]
        )
    }
}

// MARK: - Test internals

private extension Dictionary {
    typealias AddedList = [(Key, Value)]
    typealias UpdatedList = [(Key, old: Value, new: Value)]
    typealias RemovedList = [(Key, Value)]

    func assertDiffEquals(
        previous: Self,
        expectedAdded: AddedList,
        expectedUpdated: UpdatedList,
        expectedRemoved: RemovedList,
        file: StaticString = #file,
        line: UInt = #line
    ) where Key: Equatable, Value: Equatable {
        var added: AddedList = []
        var updated: UpdatedList = []
        var removed: RemovedList = []
        makeDifference(
            withPrevious: previous,
            addedList: &added,
            updatedList: &updated,
            removedList: &removed,
            areEqual: { (_, old, new) in old == new }
        )

        assertEqualUnordered(added, expectedAdded, compare: ==, file: file, line: line)
        assertEqualUnordered(updated, expectedUpdated, compare: ==, file: file, line: line)
        assertEqualUnordered(removed, expectedRemoved, compare: ==, file: file, line: line)
    }
}

extension Dictionary {
    func makeDifference(
        withPrevious previous: Dictionary,
        areEqual: (Key, _ old: Value, _ new: Value) -> Bool
    ) -> [KeyedDifference<Key, Value>] {

        var result: [KeyedDifference<Key, Value>] = []

        for (key, value) in previous where !self.keys.contains(key) {
            result.append(.removed(key, value))
        }

        for (key, value) in self {
            if let older = previous[key] {
                if !areEqual(key, older, value) {
                    result.append(.updated(key, old: older, new: value))
                }
            } else {
                result.append(.added(key, value))
            }
        }

        return result
    }

    func makeDifference(
        withPrevious previous: Dictionary,
        addedList: inout [(Key, Value)],
        updatedList: inout [(Key, old: Value, new: Value)],
        removedList: inout [(Key, Value)],
        areEqual: (Key, _ old: Value, _ new: Value) -> Bool
    ) {
        
        for (key, value) in previous where !self.keys.contains(key) {
            removedList.append((key, value))
        }

        for (key, value) in self {
            if let older = previous[key] {
                if !areEqual(key, older, value) {
                    updatedList.append((key, old: older, new: value))
                }
            } else {
                addedList.append((key, value))
            }
        }
    }
}

extension Dictionary where Value: Equatable {
    func makeDifference(withPrevious previous: Dictionary) -> [KeyedDifference<Key, Value>] {
        return makeDifference(withPrevious: previous, areEqual: { $1 == $2 })
    }
}

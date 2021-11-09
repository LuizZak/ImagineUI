enum KeyedDifference<Key, Value> {
    case removed(Key, Value)
    case added(Key, Value)
    case updated(Key, old: Value, new: Value)
}

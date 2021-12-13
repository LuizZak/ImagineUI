internal extension String {
    subscript<R>(characterRange r: R) -> Substring where R : RangeExpression, R.Bound == Int {
        let range = r.relative(to: DummyCollection(startIndex: 0, endIndex: count))
        
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(startIndex, offsetBy: range.upperBound)
        
        return self[start..<end]
    }
}

private struct DummyCollection: Collection {
    var startIndex: Int
    var endIndex: Int
    
    subscript(position: Int) -> Void {
        return ()
    }
    
    func index(after i: Int) -> Int {
        return i + 1
    }
}

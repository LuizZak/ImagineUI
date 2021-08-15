/// Represents a collection of Rectangle objects that can be combine using boolean
/// operators
public protocol Region {
    /// Returns the rectangular scans that fill the area of this region
    func scans() -> [Rectangle]
    
    /// Combines this region with another region object using a given operator
    mutating func combine(with other: Region, operation: RegionOperator)
    
    /// Combines this region with a given rectangle using a given operator
    mutating func combine(_ rect: Rectangle, operation: RegionOperator)
}

public enum RegionOperator {
    case subtract
    case and
    case or
    case xor
}
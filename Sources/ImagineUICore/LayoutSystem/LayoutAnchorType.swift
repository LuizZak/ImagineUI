public protocol LayoutAnchorType: CustomStringConvertible {
    var kind: AnchorKind { get }
    var owner: AnyObject? { get }
}

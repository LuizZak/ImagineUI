import Geometry

/// Stores information about a view or layout guide's location and size, which
/// can be later restored
struct LayoutAreaSnapshot {
    var layoutContainer: LayoutVariablesContainer
    var area: UIRectangle
    
    func restore() {
        layoutContainer.area = area
    }
    
    static func snapshot(_ layoutContainer: LayoutVariablesContainer) -> LayoutAreaSnapshot {
        return LayoutAreaSnapshot(layoutContainer: layoutContainer, area: layoutContainer.area)
    }
    
    /// Snapshots an entire view's hierarchy, including layout guides
    static func snapshotHierarchy(_ view: View) -> [LayoutAreaSnapshot] {
        var snapshots: [LayoutAreaSnapshot] = []
        let visitor = ClosureViewVisitor<Void> { (_, view) in
            snapshots.append(snapshot(view))
            
            for layoutGuide in view.layoutGuides {
                snapshots.append(snapshot(layoutGuide))
            }
        }
        let traveler = ViewTraveler(visitor: visitor)
        traveler.travelThrough(view: view)
        
        return snapshots
    }
}

extension Sequence where Element == LayoutAreaSnapshot {
    func restore() {
        for snapshot in self {
            snapshot.restore()
        }
    }
}

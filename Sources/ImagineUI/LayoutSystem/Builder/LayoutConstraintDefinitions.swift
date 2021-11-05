/// A list of layout constraint definitions that can be used to create and/or 
/// update constraints on a view.
public struct LayoutConstraintDefinitions {
    var definitions: [LayoutConstraintDefinition]

    /// Creates the layout constraints defined within this `LayoutConstraintDefinitions`
    /// object.
    @discardableResult
    public func create() -> [LayoutConstraint] {
        return definitions.map {
            $0.create()
        }
    }
    
    /// Updates the layout constraints referenced by this `LayoutConstraintDefinitions`
    /// object.
    @discardableResult
    public func update() -> [LayoutConstraint] {
        return definitions.map {
            $0.update()
        }
    }
}

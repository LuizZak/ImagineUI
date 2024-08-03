/// A list of layout constraint definitions that can be used to create and/or
/// update constraints on a view.
public struct LayoutConstraintDefinitions {
    // TODO: Mark as @usableFromInline to fix a crash when building ImagineUI dependency for release
    @usableFromInline
    var definitions: [LayoutConstraintDefinition]

    /// Returns all layout containers affected by constraints defined within this
    /// layout constraint definition.
    func affectedContainers() -> [LayoutVariablesContainer] {
        definitions.flatMap(\.affectedContainers)
    }

    /// If the affected containers within this layout constraint definition collection
    /// have a common superview, returns that superview.
    ///
    /// In case all constraints affect a single view, that view is returned.
    func commonAffectedSuperview() -> View? {
        let views = affectedContainers().compactMap(\.viewInHierarchy)
        guard let first = views.first else {
            return nil
        }

        var ancestor = first
        for view in views.dropFirst() {
            guard let next = View.firstCommonAncestor(between: ancestor, view) else {
                return nil
            }

            ancestor = next
        }

        return ancestor
    }

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
    ///
    /// Note: This method assumes the referenced constraints already exist. If
    /// one or more of the constraints does not exist, the method traps with a
    /// `fatalError`.
    @discardableResult
    public func update() -> [LayoutConstraint] {
        return definitions.map {
            $0.update()
        }
    }
}

public extension LayoutConstraintDefinitions {
    static func | (
        lhs: LayoutConstraintDefinitions,
        rhs: LayoutPriority
    ) -> LayoutConstraintDefinitions {

        .init(definitions: lhs.definitions.map {
            $0 | rhs
        })
    }
}

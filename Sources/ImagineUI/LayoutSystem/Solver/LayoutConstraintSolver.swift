public class LayoutConstraintSolver {
    public func solve(viewHierarchy: View, cache: LayoutConstraintSolverCache? = nil) {
        let visitor = ClosureViewVisitor<ConstraintCollection> { collection, view in
            collection.affectedLayoutVariables.append(view.layoutVariables)
            for guide in view.layoutGuides {
                collection.affectedLayoutVariables.append(guide.layoutVariables)
            }

            for constraint in view.containedConstraints where constraint.isEnabled {
                collection.constraints.append(constraint)
            }
        }
        let result = ConstraintCollection()
        let traveler = ViewTraveler(state: result, visitor: visitor)
        traveler.travelThrough(view: viewHierarchy)

        let locCache = cache ?? LayoutConstraintSolverCache()

        locCache.saveState()

        register(result: result, cache: locCache)

        let diff = locCache.compareState()

        do {
            try locCache.updateSolver(diff)
        } catch {
            print("Error solving layout constraints: \(error)")
        }

        locCache.solver.updateVariables()

        for view in result.affectedLayoutVariables {
            view.applyVariables()
        }
    }

    private func register(result: ConstraintCollection,
                          cache: LayoutConstraintSolverCache) {

        for affectedView in result.affectedLayoutVariables {
            affectedView.deriveConstraints(cache.constraintList(for: affectedView.container))
        }

        cache.inspectConstraints(result.constraints)
    }
}

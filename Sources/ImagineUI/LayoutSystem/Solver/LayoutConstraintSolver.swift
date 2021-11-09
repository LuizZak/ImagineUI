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

        do {
            try locCache.update(result: result)
        } catch {
            print("Error solving layout constraints: \(error)")
        }

        locCache.updateVariables()

        for view in result.affectedLayoutVariables {
            view.applyVariables()
        }
    }
}

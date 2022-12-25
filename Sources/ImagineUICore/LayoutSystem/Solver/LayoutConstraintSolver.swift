public class LayoutConstraintSolver {
    public func solve(viewHierarchy: View, cache: LayoutConstraintSolverCache? = nil) {
        let locCache =
            cache ??
            LayoutConstraintSolverCache()

        do {
            let spatialReference = viewHierarchy.superview
            
            let result = try locCache.update(fromView: viewHierarchy, rootSpatialReference: spatialReference)

            for variables in result.affectedLayoutVariables {
                variables.applyVariables(relativeTo: spatialReference)
            }
        } catch {
            print("Error solving layout constraints: \(error)")
        }
    }
}

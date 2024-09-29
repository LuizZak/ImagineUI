public class LayoutConstraintSolver {
    @ImagineActor
    public func solve(viewHierarchy: View, cache: LayoutConstraintSolverCache? = nil) {
        let locCache =
            cache ??
            LayoutConstraintSolverCache()

        do {
            let spatialReference = viewHierarchy.superview

            let result = try locCache.update(fromView: viewHierarchy, rootSpatialReference: spatialReference)

            for (container, variables) in result.affectedLayoutVariables {
                variables.applyVariables(
                    container: container,
                    relativeTo: spatialReference
                )
            }
        } catch {
            ImagineUILogger.logger?.error("Error solving layout constraints: \(error)")
            locCache.reset()
        }
    }
}

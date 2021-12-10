public class LayoutConstraintSolver {
    public func solve(viewHierarchy: View, cache: LayoutConstraintSolverCache? = nil) {
        let locCache = cache ?? LayoutConstraintSolverCache()

        do {
            let result = try locCache.update(fromView: viewHierarchy)

            for variables in result.affectedLayoutVariables {
                variables.applyVariables(relativeTo: viewHierarchy)
            }
        } catch {
            print("Error solving layout constraints: \(error)")
        }
    }
}

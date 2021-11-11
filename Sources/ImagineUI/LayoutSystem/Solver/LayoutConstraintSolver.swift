public class LayoutConstraintSolver {
    public func solve(viewHierarchy: View, cache: LayoutConstraintSolverCache? = nil) {
        let locCache = cache ?? LayoutConstraintSolverCache()

        do {
            let result = try locCache.update(fromView: viewHierarchy)

            for view in result.affectedLayoutVariables {
                view.applyVariables()
            }
        } catch {
            print("Error solving layout constraints: \(error)")
        }
    }
}

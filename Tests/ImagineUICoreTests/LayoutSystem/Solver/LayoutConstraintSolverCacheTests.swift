import XCTest

@testable import ImagineUICore

class LayoutConstraintSolverCacheTests: XCTestCase {
    func testInternal_compareAndApplyStates_addingConstraints() throws {
        let sut = makeInternalSut()
        let view = View()
        sut.test_register(view)
        try sut.test_compareAndApply()

        view.layout.makeConstraints { make in
            make.width == 100
        }
        sut.test_register(view)
        try sut.test_compareAndApply()
    }

    func testInternal_compareAndApplyStates_removingConstraints() throws {
        let sut = makeInternalSut()
        let view = View()
        let constraints = view.layout.makeConstraints { make in
            make.width == 100
        }
        sut.test_register(view)
        try sut.test_compareAndApply()

        constraints.forEach {
            $0.removeConstraint()
        }
        sut.test_register(view)
        try sut.test_compareAndApply()
    }

    func testInternal_compareAndApplyStates_stackView_addArrangedSubview() throws {
        let sut = makeInternalSut()
        let view = StackView(orientation: .horizontal)
        sut.test_register(view)

        view.addArrangedSubview(View())
        sut.test_register(view)
        try sut.test_compareAndApply()

        view.addArrangedSubview(View())
        sut.test_register(view)
        try sut.test_compareAndApply()

        view.addArrangedSubview(View())
        sut.test_register(view)
        try sut.test_compareAndApply()

        view.addArrangedSubview(View())
        sut.test_register(view)
        try sut.test_compareAndApply()
    }
}

// MARK: - Test internals

private func makeSut() -> LayoutConstraintSolverCache {
    return LayoutConstraintSolverCache()
}

private func makeInternalSut() -> _LayoutConstraintSolverCache {
    return _LayoutConstraintSolverCache()
}

private extension _LayoutConstraintSolverCache {
    func test_register(_ view: View) {
        saveState()

        let visitor = LayoutConstraintSolverCache.ConstraintViewVisitor(rootView: view)
        let traveler = ViewTraveler(state: ConstraintCollection(), visitor: visitor)
        traveler.travelThrough(view: view)

        let result = traveler.state
        let orientations: Set<LayoutConstraintOrientation> = [.horizontal, .vertical, .mixed]
        let rootSpatialReference = view

        register(
            result: result,
            orientations: orientations,
            rootSpatialReference: rootSpatialReference
        )
    }

    func test_compareAndApply() throws {
        let orientations: Set<LayoutConstraintOrientation> = [.horizontal, .vertical, .mixed]

        try compareAndApplyStates(orientations: orientations)
    }
}

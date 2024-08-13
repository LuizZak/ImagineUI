import Foundation
import Geometry
import Rendering

/// Base class for views in ImagineUI.
///
/// Can be instantiated and used as container as-is or subclassed to provide
/// custom behaviour, if required.
open class View {
    /// If `true`, setting `self.location` or `self.bounds` skips calling `setNeedsLayout`
    /// internally.
    private var _skipSetNeedsLayoutOnBounds: Bool = false

    /// An override to intrinsicSize. Used by View's methods that calculate
    /// minimal content sizes.
    internal var _targetLayoutSize: UISize? = nil

    var horizontalCompressResistance: LayoutPriority? = .high {
        didSet {
            if oldValue != horizontalCompressResistance {
                setNeedsLayout()
            }
        }
    }
    var verticalCompressResistance: LayoutPriority? = .high {
        didSet {
            if oldValue != verticalCompressResistance {
                setNeedsLayout()
            }
        }
    }

    var horizontalHuggingPriority: LayoutPriority? = .veryLow {
        didSet {
            if oldValue != horizontalHuggingPriority {
                setNeedsLayout()
            }
        }
    }
    var verticalHuggingPriority: LayoutPriority? = .veryLow {
        didSet {
            if oldValue != verticalHuggingPriority {
                setNeedsLayout()
            }
        }
    }

    var layoutVariables: LayoutVariables!

    var layoutSuspendStackDepth: Int = 0
    var invalidateSuspendStackDepth: Int = 0

    /// Whether the layout of this view is suspended.
    ///
    /// When layout is suspended, the view does not propagate ``setNeedsLayout``
    /// invocations to parent views.
    public var isLayoutSuspended: Bool {
        return layoutSuspendStackDepth > 0
    }

    /// Whether the invalidations issued by this view or one of its subviews are
    /// suspended.
    ///
    /// When invalidations are suspended, the view does not propagate `invalidate`
    /// invocations to parent views.
    public var isInvalidateSuspended: Bool {
        return invalidateSuspendStackDepth > 0
    }

    var rootView: RootView? {
        if let rootView = self as? RootView {
            return rootView
        }

        return superview?.rootView
    }

    public internal(set) var needsLayout: Bool = true

    /// A rotation around the relative transform center of this view, in radians.
    ///
    /// This affects the display and hit test of this view's entire hierarchy,
    /// but might affect constraint resolution in unintuitive ways.
    ///
    /// Defaults `U0`.
    ///
    /// - seealso: `relativeTransformCenter`
    open var rotation: Double = 0 {
        willSet {
            guard rotation != newValue else { return }

            invalidate()
        }
        didSet {
            guard rotation != oldValue else { return }

            invalidate()
        }
    }

    /// A visual scale for the view relative to the transform center of this
    /// view.
    ///
    /// Affects all of this view's rendering and hit test hierarchy, but might
    /// affect constraint resolution in unintuitive ways.
    ///
    /// Defaults `UIVector(x: 1, y: 1)`.
    ///
    /// - seealso: `relativeTransformCenter`
    open var scale: UIVector = UIVector(x: 1, y: 1) {
        willSet {
            guard scale != newValue else { return }

            invalidate()
        }
        didSet {
            guard scale != oldValue else { return }

            invalidate()
        }
    }

    /// Whether this view naturally clips its rendering area to be within the
    /// bounds of `boundsForRedraw()` automatically.
    ///
    /// This also affects invalidation requests and queries to
    /// `isFullyVisibleOnScreen()`.
    open var clipToBounds: Bool = true {
        didSet {
            guard clipToBounds != oldValue else { return }

            invalidate()
        }
    }

    /// The center of the transform for this view.
    /// When a view is scaled and/or rotated, this value specifies the relative
    /// center of the transformation.
    ///
    /// A value of `.zero` rotates/scales around the view's top-left corner,
    /// a value of `0.5` transforms around the center of the view's bounds, and
    /// a value of `1.0` transforms around the bottom-right corner of the view.
    /// Values in between transform around the relative intermediaries.
    ///
    /// Defaults to `UIVector.zero`.
    open var relativeTransformCenter: UIVector = .zero

    /// Gets the full transform matrix for this view's translation, rotation, and
    /// scale.
    ///
    /// This
    open var transform: UIMatrix {
        let baseMatrix: UIMatrix = .transformation(
            xScale: scale.x,
            yScale: scale.y,
            angle: rotation,
            xOffset: location.x,
            yOffset: location.y
        )

        if relativeTransformCenter == .zero {
            return baseMatrix
        }

        var matrix = UIMatrix.translation(-size.asUIPoint * relativeTransformCenter)

        matrix = matrix * baseMatrix

        matrix = .translation(size.asUIPoint * relativeTransformCenter) * matrix

        return matrix
    }

    /// Gets or sets the location of this view with respect to its superview.
    public var location: UIVector {
        willSet {
            if location != newValue {
                invalidate()
            }
        }
        didSet {
            if location == oldValue {
                return
            }

            invalidate()

            if !_skipSetNeedsLayoutOnBounds && locationAffectsConstraints() {
                setNeedsLayout()
            }
        }
    }

    /// Gets or sets the relative bounds of this view as a `UIRectangle`.
    /// Since the bounds are always relative to this view's coordinate system,
    /// its top-left location is always at `UIPoint.zero` and changes to that
    /// coordinate are ignored.
    open var bounds: UIRectangle {
        willSet {
            if bounds != newValue {
                invalidate()
            }
        }
        didSet {
            bounds = UIRectangle(left: 0, top: 0, right: bounds.width, bottom: bounds.height)
            if bounds == oldValue {
                return
            }

            invalidate()

            if !_skipSetNeedsLayoutOnBounds && sizeAffectsConstraints() {
                setNeedsLayout()
            }
        }
    }

    /// Gets or sets the size of this view's bounds.
    open var size: UISize {
        get {
            return bounds.size
        }
        set {
            bounds.size = newValue
        }
    }

    /// Gets or sets this view's area, affecting both `self.location` and
    /// `self.size`.
    ///
    /// Unlike `self.bounds`, this property supports changes to `self.location`
    /// by specifying different top-left coordinates for the input rectangle.
    open var area: UIRectangle {
        get {
            return UIRectangle(x: location.x, y: location.y, width: bounds.width, height: bounds.height)
        }
        set {
            location = newValue.location
            bounds.size = newValue.size
        }
    }

    /// Controls whether this view and its subviews are rendered and interactive
    /// on screen.
    ///
    /// Hidden views do not participate in rendering and are not considered for
    /// mouse input hit tests.
    open var isVisible: Bool = true {
        didSet {
            if isVisible == oldValue { return }

            invalidate()
        }
    }

    /// Changes the alpha value of this view, which affects the base transparency
    /// of its entire view hierarchy.
    ///
    /// A value of 1.0 indicates a fully opaque view, while 0.0 indicates a fully
    /// transparent view.
    ///
    /// Views with transparency still render on screen, but the renderer context
    /// is automatically set to a lower global alpha, according to the alpha
    /// of the view's hierarchy.
    ///
    /// Value is capped to be within (0.0, 1.0) range, inclusive.
    open var alpha: Double = 1.0 {
        didSet {
            alpha = min(1.0, max(0.0, alpha))

            if isVisible && alpha != oldValue {
                invalidate()
            }
        }
    }

    /// For rendering purposes
    var effectiveAlpha: Double {
        var result = 1.0

        visitingSuperviews { view in
            result *= view.alpha
        }

        return result
    }

    // MARK: -

    /// A list of constraints that affect this view, or other subviews in the
    /// same hierarchy.
    /// Should be unique between all constraints created across the view hierarchy.
    internal var containedConstraints: [LayoutConstraint] = []

    /// A list of constraints that are affecting this view.
    internal(set) public var constraints: [LayoutConstraint] = []

    /// This view's intrinsic size.
    ///
    /// If a dimension is present, it indicates to layout systems that this view
    /// has a natural size that it reports is preferred, and content
    /// compression/hugging constraints are applied relative to it.
    ///
    /// If `none`, content compression/hugging is ignored entirely during constraint
    /// layout.
    open var intrinsicSize: IntrinsicSize {
        return .none
    }

    /// Gets the logical superview for this view.
    private(set) public weak var superview: View?

    /// Gets the list of logical subviews for this view.
    private(set) public var subviews: [View] = []

    /// Gets the list of layout guides on this view.
    ///
    /// Layout guides can interact with other layout guides and views in the
    /// same hierarchy.
    internal(set) public var layoutGuides: [LayoutGuide] = []

    /// A set of area components for this view's `self.area` that should be turned
    /// into constraints, in layout constraint systems.
    ///
    /// If a value is specified, the constraint system adds a constraint that
    /// ties that dimension to the view's current value as if it was an explicit
    /// constraint.
    ///
    /// If not empty, might interact unexpectedly with the constraint system, if
    /// other constraints affect a dimension of this view that is constrained by
    /// this property.
    public var areaIntoConstraintsMask: Set<BoundsConstraintMask> = [.location, .size] {
        didSet {
            setNeedsLayout()
        }
    }

    /// If `true`, users can interact with this view or any subview with the mouse,
    /// in case a `ControlView` lies under the mouse within this view's hierarchy.
    public var isInteractiveEnabled: Bool = true

    /// Gets the active control system for the view hierarchy.
    /// Used to handle first responder configurations.
    public var controlSystem: ControlSystemType? {
        return superview?.controlSystem
    }

    /// If `true`, reports that this view, as well as all superviews, have
    /// `isInteractiveEnabled` true.
    ///
    /// Control views that return `false` for this property are ignored in input
    /// management as if they where regular views.
    public var isRecursivelyInteractiveEnabled: Bool {
        var view: View? = self
        while let v = view {
            if !v.isInteractiveEnabled {
                return false
            }
            view = v.superview
        }

        return true
    }

    public init() {
        self.bounds = .zero
        self.location = .zero
        layoutVariables = LayoutVariables(container: self)
        setupHierarchy()
        setupConstraints()
    }

    /// Recursively renders this view's hierarchy using a specified renderer
    /// and screen-space clip region that can be queried to check the screen-space
    /// areas that are being redrawn.
    ///
    /// If this view's `clipToBounds` is `true`, the renderer's clip region is
    /// clipped further with `self.boundsForRedraw()`, but `screenRegion` is
    /// unaffected.
    public final func renderRecursive(in renderer: Renderer, screenRegion: ClipRegionType) {
        if !isVisible {
            return
        }

        if screenRegion.hitTest(boundsForRedrawOnScreen()) == .out {
            return
        }

        renderer.withTemporaryState {
            renderer.transform(transform)
            if clipToBounds {
                renderer.clip(boundsForRedraw())
            }
            renderer.setGlobalAlpha(effectiveAlpha)

            render(in: renderer, screenRegion: screenRegion)

            for view in subviews {
                view.renderRecursive(in: renderer, screenRegion: screenRegion)
            }
        }
    }

    /// Renders this view's contents on a given renderer.
    ///
    /// This pertains to rendering of this view's contents, and not any of its
    /// subviews.
    open func render(in context: Renderer, screenRegion: ClipRegionType) {

    }

    /// Suspends invalidate() from affecting this view and its parent
    /// hierarchy.
    ///
    /// Sequential calls to `suspendInvalidation()` must be balanced with a matching
    /// number of `resumeInvalidation(invalidate:)` calls later in order for
    /// invalidation to resume successfully.
    open func suspendInvalidation() {
        invalidateSuspendStackDepth += 1
    }

    /// Resumes invalidation, optionally dispatching a `invalidate()` call
    /// to the view at the end.
    ///
    /// Sequential calls to `resumeInvalidation(invalidate:)` must be balanced
    /// with a matching number of earlier `suspendInvalidation()` calls in order for
    /// invalidation to resume successfully.
    open func resumeInvalidation(invalidate: Bool) {
        if invalidateSuspendStackDepth > 0 {
            invalidateSuspendStackDepth -= 1
        }

        if invalidateSuspendStackDepth == 0 && invalidate {
            self.invalidate()
        }
    }

    /// Performs a given closure while suspending the invalidation of this view,
    /// optionally dispatching a `invalidate()` call to the view at the end.
    ///
    /// Invalidation is resumed whether or not the closure throws before the end
    /// of the block.
    open func withSuspendedInvalidation<T>(invalidate: Bool, _ block: () throws -> T) rethrows -> T {
        suspendInvalidation()
        defer {
            resumeInvalidation(invalidate: invalidate)
        }

        return try block()
    }

    // MARK: - Redraw Invalidation

    /// Invalidates the entire redraw boundaries of this view.
    ///
    /// Equivalent to `self.invalidate(bounds: self.boundsForRedraw())`.
    open func invalidate() {
        invalidate(bounds: boundsForRedraw())
    }

    /// Invalidates a specified region of this view's boundaries.
    open func invalidate(bounds: UIRectangle) {
        guard !isInvalidateSuspended else { return }

        var bounds = bounds
        if clipToBounds {
            bounds = bounds.intersection(self.boundsForRedraw()) ?? .zero
        }
        if bounds.width <= 0 || bounds.height <= 0 {
            return
        }

        invalidate(bounds: bounds, spatialReference: self)
    }

    internal func invalidate(bounds: UIRectangle, spatialReference: SpatialReferenceType) {
        guard !isInvalidateSuspended else { return }

        superview?.invalidate(bounds: bounds, spatialReference: spatialReference)
    }

    /// Returns a rectangle that represents the invalidation and redraw area of
    /// this view in its local coordinates.
    ///
    /// Defaults to `self.bounds` on `View` class.
    open func boundsForRedraw() -> UIRectangle {
        return bounds
    }

    /// Returns the bounds for redrawing on the superview's coordinate system
    func boundsForRedrawOnSuperview() -> UIRectangle {
        return transform.transform(boundsForRedraw())
    }

    /// Returns the bounds for redrawing on the screen's coordinate system
    func boundsForRedrawOnScreen() -> UIRectangle {
        return absoluteTransform().transform(boundsForRedraw())
    }

    // MARK: - Layout

    /// Method automatically called by `View.init()` that can be used to create
    /// view hierarchies before they are constrained by `View.setupConstraints()`.
    ///
    /// Used as a convenience for generating new view subclasses; view hierarchies
    /// can be changed at any point in a view's lifecycle.
    ///
    /// - seealso: `setupConstraints()`
    open func setupHierarchy() {

    }

    /// Method automatically called by `View.init()` that can be used to create
    /// constraints between subviews in this view's hierarchy after they are
    /// created by `View.setupHierarchy()`.
    ///
    /// Used as a convenience for generating new view subclasses; view constraints
    /// can be changed at any point in a view's lifecycle.
    ///
    /// - seealso: `setupHierarchy()`
    open func setupConstraints() {

    }

    /// Removes all constraints that currently affects this view.
    open func removeAffectingConstraints() {
        for constraint in constraints {
            constraint.removeConstraint()
        }
    }

    /// Recursively invokes `performLayout()` and `performInternalLayout()` on
    /// all subviews.
    open func performLayout() {
        if !needsLayout {
            return
        }

        withSuspendedLayout(setNeedsLayout: false) {
            performInternalLayout()
        }

        needsLayout = false

        for subview in subviews {
            subview.performLayout()
        }
    }

    /// Requests that this view perform its internal layout, while ignoring
    /// layout of subviews.
    open func performInternalLayout() {
        /// If no superview is available, perform constraint layout locally,
        /// instead.
        if superview == nil {
            performConstraintsLayout(cached: true)
        }
    }

    internal func performConstraintsLayout(cached: Bool) {
        let solver = LayoutConstraintSolver()
        solver.solve(viewHierarchy: self, cache: nil)
    }

    /// If `true`, indicates that this view has an internal layout that is
    /// self-contained and can be solved deterministically regardless of the
    /// layout state of superviews.
    ///
    /// This makes the Cassowary layout constraint system ignore this view and
    /// any subview in its hierarchy during constraint resolution of superviews.
    ///
    /// If a view returns `true` but contains constraints that relate it to a
    /// view outside its hierarchy, an undefined layout behavior can occur.
    open func hasIndependentInternalLayout() -> Bool {
        false
    }

    /// Suspends setNeedsLayout() from affecting this view and its parent
    /// hierarchy.
    ///
    /// Sequential calls to `suspendLayout()` must be balanced with a matching
    /// number of `resumeLayout(setNeedsLayout:)` calls later in order for
    /// layout to resume successfully.
    open func suspendLayout() {
        layoutSuspendStackDepth += 1
    }

    /// Resumes layout, optionally dispatching a `setNeedsLayout()` call to the
    /// view at the end.
    ///
    /// Sequential calls to `resumeLayout(setNeedsLayout:)` must be balanced
    /// with a matching number of earlier `suspendLayout()` calls in order for
    /// layout to resume successfully.
    open func resumeLayout(setNeedsLayout: Bool) {
        if layoutSuspendStackDepth > 0 {
            layoutSuspendStackDepth -= 1
        }

        if layoutSuspendStackDepth == 0 && setNeedsLayout {
            self.setNeedsLayout()
        }
    }

    /// Performs a given closure while suspending the layout of this view,
    /// optionally dispatching a `setNeedsLayout()` call to the view at the end.
    ///
    /// Layout is resumed whether or not the closure throws before the end of
    /// the block.
    open func withSuspendedLayout<T>(setNeedsLayout: Bool, _ block: () throws -> T) rethrows -> T {
        suspendLayout()
        defer {
            resumeLayout(setNeedsLayout: setNeedsLayout)
        }

        return try block()
    }

    /// Marks this view as requiring a layout pass on the next system's layout
    /// pass loop.
    ///
    /// Also invokes `setNeedsLayout()` on superviews recursively.
    open func setNeedsLayout() {
        guard !isLayoutSuspended else { return }

        superview?.setNeedsLayout()
        needsLayout = true
    }

    /// Calculates the optimal size for this view, taking in consideration its
    /// active constraints, while approaching the target size as much as possible.
    ///
    /// The view's bounds then changes to match the calculated size, with its
    /// location left unchanged.
    ///
    /// This method also calls 'performLayout()' afterwards to update its contents.
    open func layoutToFit(size: UISize) {
        self.size = layoutSizeFitting(size: size)

        performLayout()
    }

    /// Calculates the optimal size for this view, taking in consideration its
    /// active constraints, while approaching the target size as much as possible.
    /// The layout of the view is kept as-is, and no changes to its size are made.
    open func layoutSizeFitting(size: UISize) -> UISize {
        return withSuspendedLayout(setNeedsLayout: false) {
            return withSuspendedInvalidation(invalidate: false) {
                // Store state for later restoring
                let previousAreaIntoConstraintsMask = areaIntoConstraintsMask
                let snapshot = LayoutAreaSnapshot.snapshotHierarchy(self)

                _targetLayoutSize = size
                areaIntoConstraintsMask = [.location]

                performConstraintsLayout(cached: false)

                let optimalSize = self.size

                // Restore views back to previous state
                snapshot.restore()
                _targetLayoutSize = nil
                areaIntoConstraintsMask = previousAreaIntoConstraintsMask

                // Update constraint cache back
                performConstraintsLayout(cached: true)

                return optimalSize
            }
        }
    }

    // MARK: - Subviews

    /// Adds a given subview as a direct child of this view's hierarchy.
    ///
    /// Views in nested hierarchies inherit coordinate systems of parent views.
    ///
    /// - precondition: `view` is not this view, or any superview from this view.
    open func addSubview(_ view: View) {
        if isDescendant(of: view) {
            fatalError("Attempted to add a view as a subview of its own hierarchy: \(self).addSubview(\(view)).")
        }

        view.removeFromSuperview()

        view.superview = self
        subviews.append(view)

        setNeedsLayout()
        view.invalidate()

        didAddSubview(view)

        view.superviewDidChange(self)
    }

    /// Function called after a view has been added as a subview of this view.
    open func didAddSubview(_ view: View) {

    }

    /// Function called before a view is removed as a subview of this view instance.
    ///
    /// - note: Do not add `view` to any other view hierarchy within this method.
    open func willRemoveSubview(_ view: View) {
        controlSystem?.viewRemovedFromHierarchy(view)
    }

    /// Removes this view from its superview's hierarchy.
    ///
    /// Constraints that where created that cross the superview's boundaries are
    /// removed, but not constraints that reference this view and/or one of its
    /// children exclusively.
    open func removeFromSuperview() {
        guard let superview = superview else {
            return
        }

        invalidate()

        superview.willRemoveSubview(self)

        // Remove all constraints that involve this view, or one of its subviews.
        // We check parent views only because the way containedConstraints are
        // stored, each constraint is guaranteed to only affect the view itself
        // or one of its subviews, thus we check the parent hierarchy for
        // constraints involving this view tree, but not the child hierarchy.
        superview.visitingSuperviews { view in
            for constraint in view.containedConstraints {
                if constraint.firstCast._owner?.viewInHierarchy?.isDescendant(of: self) == true {
                    constraint.removeConstraint()
                }
                if constraint.secondCast?._owner?.viewInHierarchy?.isDescendant(of: self) == true {
                    constraint.removeConstraint()
                }
            }
        }

        superview.subviews.removeAll(where: { $0 === self })
        self.superview = nil

        superviewDidChange(nil)
    }

    /// Called when the superview of this view has changed.
    open func superviewDidChange(_ newSuperview: View?) {

    }

    /// Brings this view to the end of this view's superview's subviews list.
    ///
    /// Has implications for display and user interactions, as views that are
    /// last on the subviews list get rendered on top, and receive priority for
    /// mouse events as a consequence.
    ///
    /// If this view has no superview, nothing is done.
    open func bringToFrontOfSuperview() {
        guard let superview = superview, let index = superview.subviews.firstIndex(of: self) else {
            return
        }

        superview.subviews.remove(at: index)
        superview.subviews.append(self)

        invalidate()
    }

    /// Brings this view to be one subview higher than another sibling view in
    /// their common superview's subviews list.
    ///
    /// Has implications for display and user interactions, as views that are
    /// last on the subviews list get rendered on top, and receive priority for
    /// mouse events as a consequence.
    ///
    /// If this view has no superview, or it does not share a common superview
    /// with `siblingView`, nothing is done.
    open func bringInFrontOfSiblingView(_ siblingView: View) {
        guard let superview = superview, siblingView.superview == superview else {
            return
        }
        guard let index = superview.subviews.firstIndex(of: self) else {
            return
        }

        superview.subviews.remove(at: index)

        guard let siblingIndex = superview.subviews.firstIndex(of: siblingView) else {
            // View is sibling but has no index in superview?
            // Re-insert self and quit.
            superview.subviews.insert(self, at: index)
            return
        }

        superview.subviews.insert(self, at: siblingIndex + 1)

        invalidate()
    }

    /// A method that should return the subview from this view hierarchy to which
    /// firstBaseline constraints should be attached to.
    ///
    /// If `nil`, the baseline is derived from this view's baseline.
    open func viewForFirstBaseline() -> View? {
        return nil
    }

    // MARK: - Layout Guides

    /// Adds a given layout guide to this view's hierarchy.
    ///
    /// Layout guides can be used as supporting layout areas for constraining
    /// views without requiring expensive `View` instances as guides themselves.
    open func addLayoutGuide(_ guide: LayoutGuide) {
        guide.removeFromSuperview()

        guide.owningView = self
        layoutGuides.append(guide)
    }

    /// Called when a layout guide is being removed from this view's hierarchy.
    ///
    /// - note: Do not add `guide` to any other view hierarchy within this method.
    open func willRemoveLayoutGuide(_ guide: LayoutGuide) {

    }

    /// Gets the absolute transformation matrix that encodes the exact transform
    /// of this view according to all its parent view's transforms combined.
    ///
    /// This matrix can then be used to transform from/to this view's local
    /// coordinate space.
    open func absoluteTransform() -> UIMatrix {
        var transform = self.transform
        if let superview = superview {
            transform = transform * superview.absoluteTransform()
        }
        return transform
    }

    /// Transforms a given point from this view's local coordinate space into
    /// another spatial reference's coordinate space.
    ///
    /// If `other` is `nil`, the final point can be interpreted as screen-space,
    /// if the root view's (0, 0) coordinate is on the top-left of a window.
    open func convert(point: UIVector, to other: SpatialReferenceType?) -> UIVector {
        var point = point
        point *= absoluteTransform()
        if let other = other {
            point *= other.absoluteTransform().inverted()
        }
        return point
    }

    /// Transforms a given point from another spatial reference's coordinate
    /// space to this view's local coordinate space.
    ///
    /// If `other` is `nil`, the initial point can be interpreted as screen-space,
    /// if the root view's (0, 0) coordinate is on the top-left of a window.
    open func convert(point: UIVector, from other: SpatialReferenceType?) -> UIVector {
        var point = point
        if let other = other {
            point *= other.absoluteTransform()
        }
        point *= absoluteTransform().inverted()

        return point
    }

    /// Transforms a given rectangle from this view's local coordinate space into
    /// another spatial reference's coordinate space.
    ///
    /// If rotations where applied to the rectangle, the final rectangle is still
    /// axis-aligned, but stretched to fit the corners of the rotated rectangle.
    ///
    /// If `other` is `nil`, the final rectangle can be interpreted as screen-space,
    /// if the root view's (0, 0) coordinate is on the top-left of a window.
    open func convert(bounds: UIRectangle, to other: SpatialReferenceType?) -> UIRectangle {
        var bounds = bounds
        bounds = absoluteTransform().transform(bounds)
        if let other = other {
            bounds = other.absoluteTransform().inverted().transform(bounds)
        }
        return bounds
    }

    /// Transforms a given rectangle from another spatial reference's coordinate
    /// space to this view's local coordinate space.
    ///
    /// If rotations where applied to the rectangle, the final rectangle is still
    /// axis-aligned, but stretched to fit the corners of the rotated rectangle.
    ///
    /// If `other` is `nil`, the initial rectangle can be interpreted as screen-space,
    /// if the root view's (0, 0) coordinate is on the top-left of a window.
    open func convert(bounds: UIRectangle, from other: SpatialReferenceType?) -> UIRectangle {
        var bounds = bounds
        if let other = other {
            bounds = other.absoluteTransform().transform(bounds)
        }
        bounds = absoluteTransform().inverted().transform(bounds)
        return bounds
    }

    /// Convenience for `convert(point: point, from: nil)`.
    ///
    /// - seealso: `convert(point:from:)`.
    open func convertFromScreen(_ point: UIVector) -> UIVector {
        return convert(point: point, from: nil)
    }

    // MARK: - Bounds / Hit testing

    /// Performs a hit test operation on the area of this, and all child base
    /// views, for the given point that is relative to this view's coordinate
    /// system.
    ///
    /// Returns the first base view that crosses the point.
    ///
    /// The `inflatingArea` argument can be used to inflate the area of the
    /// views to perform less precise hit tests.
    open func viewUnder(point: UIVector, inflatingArea: UIVector = .zero) -> View? {
        guard contains(point: point, inflatingArea: inflatingArea) else {
            return nil
        }

        // Search children first
        for baseView in subviews.reversed() {
            if let ht = baseView.viewUnder(
                point: baseView.transform.inverted().transform(point),
                inflatingArea: inflatingArea
            ) {
                return ht
            }
        }

        return self
    }

    /// Performs a hit test operation on the area of this, and all child base
    /// views, for the given point that is relative to this view's coordinate
    /// system.
    ///
    /// Returns the first base view that crosses the point and returns true for
    /// `predicate`.
    ///
    /// The `inflatingArea` argument can be used to inflate the area of the views
    /// to perform less precise hit tests.
    open func viewUnder(
        point: UIVector,
        inflatingArea: UIVector = .zero,
        predicate: (View) -> Bool
    ) -> View? {

        guard contains(point: point, inflatingArea: inflatingArea) else {
            return nil
        }

        // Search children first
        for baseView in subviews.reversed() {
            if let ht = baseView.viewUnder(
                point: baseView.transform.inverted().transform(point),
                inflatingArea: inflatingArea,
                predicate: predicate
            ) {
                return ht
            }
        }

        // Test this instance now
        if predicate(self) {
            return self
        }

        return nil
    }

    /// Returns an enumerable of all views that cross the given point.
    ///
    /// The `inflatingArea` argument can be used to inflate the area of the views
    /// to perform less precise hit tests.
    ///
    /// - Parameter point: Point to test, relative to this view's coordinate
    /// system.
    /// - Parameter inflatingArea: Used to inflate the area of the views to
    /// perform less precise hit tests.
    /// - Returns: An array where each view returned crosses the given point.
    open func viewsUnder(point: UIVector, inflatingArea: UIVector = .zero) -> [View] {
        var views: [View] = []

        internalViewsUnder(point: point, inflatingArea, &views)

        return views
    }

    private func internalViewsUnder(
        point: UIVector,
        _ inflatingArea: UIVector,
        _ target: inout [View]
    ) {

        guard contains(point: point, inflatingArea: inflatingArea) else {
            return
        }

        for view in subviews.reversed() {
            let transformedPoint = view.transform.inverted().transform(point)
            // Early out this view
            if !view.contains(point: transformedPoint, inflatingArea: inflatingArea) {
                continue
            }

            view.internalViewsUnder(point: transformedPoint, inflatingArea, &target)
        }

        target.append(self)
    }

    /// Returns an enumerable of all views that cross the given `UIRectangle` bounds.
    ///
    /// The `inflatingArea` argument can be used to inflate the area of the views
    /// to perform less precise hit tests.
    ///
    /// The `UIRectangle` is converted into local bounds for each subview, so
    /// distortion may occur and result in inaccurate results for views that are
    /// rotated. There are no alternatives for this, currently.
    ///
    /// - Parameter point: rectangle to test, relative to this view's coordinate
    /// system.
    /// - Parameter inflatingArea: Used to inflate the area of the views to perform
    /// less precise hit tests.
    /// - Returns: An enumerable where each view returned intersects the given
    /// `UIRectangle`
    open func viewsUnder(area: UIRectangle, inflatingArea: UIVector = .zero) -> [View] {
        var views: [View] = []

        internalViewsUnder(area: area, inflatingArea, &views)

        return views
    }

    private func internalViewsUnder(area: UIRectangle, _ inflatingArea: UIVector, _ target: inout [View]) {
        for view in subviews.reversed() {
            let transformed = view.transform.transform(area)

            // Early out this view
            if !view.intersects(area: transformed, inflatingArea: inflatingArea) {
                continue
            }

            view.internalViewsUnder(area: transformed, inflatingArea, &target)
        }

        // Test this instance now
        if intersects(area: area, inflatingArea: inflatingArea) {
            target.append(self)
        }
    }

    /// Returns true if the given vector point intersects this view's area when
    /// inflated by a specified amount.
    ///
    /// Children views' bounds do not affect the hit test- it happens only on
    /// this view's `bounds` area.
    ///
    /// - Parameter point: Point to test
    /// - Parameter inflatingArea: Used to inflate the area of the view to
    /// perform less precise hit tests.
    open func contains(point: UIVector, inflatingArea: UIVector = .zero) -> Bool {
        if inflatingArea == .zero {
            return bounds.contains(point)
        }

        return bounds.insetBy(x: -inflatingArea.x, y: -inflatingArea.y).contains(point)
    }

    /// Returns true if the given `UIRectangle` intersects this view's area when
    /// inflated by a specified amount.
    ///
    /// Children views' bounds do not affect the hit test- it happens only on
    /// this view's `bounds` area.
    ///
    /// - Parameter area: area to test
    /// - Parameter inflatingArea: Used to inflate the area of the view to
    /// perform less precise hit tests.
    open func intersects(area: UIRectangle, inflatingArea: UIVector = .zero) -> Bool {
        return bounds.insetBy(x: -inflatingArea.x, y: -inflatingArea.y).intersects(area)
    }

    /// Returns `true` if a given rectangle within this view's local coordinate
    /// system is fully visible on the top-most view of this view's hierarchy.
    ///
    /// Results are invalid if a view is not contained in a hierarchy that is
    /// associated with a visible window area.
    open func isFullyVisibleOnScreen(area: UIRectangle) -> Bool {
        isFullyVisibleOnScreen(area: bounds, spatialReference: self)
    }

    /// Returns `true` if a given rectangle on another spatial reference is fully
    /// visible on the top-most view of this view's hierarchy.
    ///
    /// If `self.clipToBounds == true`, the rectangle is checked first against
    /// the bounds of this view.
    ///
    /// If the area is contained within this view's visible area, `superview` is
    /// then queried recursively until a hierarchy's root view is reached. If all
    /// recursive checks of containment are true, the result is `true`.
    ///
    /// Results are invalid if a view is not contained in a hierarchy that is
    /// associated with a visible window area.
    open func isFullyVisibleOnScreen(area: UIRectangle, spatialReference: SpatialReferenceType) -> Bool {
        let converted = convert(bounds: area, from: spatialReference)

        guard !clipToBounds || boundsForRedraw().contains(converted) else {
            return false
        }

        if let superview = superview {
            return superview.isFullyVisibleOnScreen(area: area, spatialReference: spatialReference)
        }

        return true
    }

    // MARK: - Content Compression/Hugging configuration

    /// Sets the content compression resistance of this view on a given orientation.
    ///
    /// Content compression resistance adds a minimal size constraint when the
    /// view has a non-nil `intrinsicSize`.
    ///
    /// If `nil` is provided as a priority, it indicates the view makes no attempt
    /// at ensuring that its size at the specified orientation be at least as
    /// large as its `intrinsicSize` property.
    public func setContentCompressionResistance(_ orientation: LayoutAnchorOrientation,
                                                _ priority: LayoutPriority?) {
        switch orientation {
        case .horizontal: horizontalCompressResistance = priority
        case .vertical: verticalCompressResistance = priority
        }
    }

    /// Gets the current content compression resistance of this view on the given
    /// orientation.
    public func contentCompressionResistance(_ orientation: LayoutAnchorOrientation) -> LayoutPriority? {
        switch orientation {
        case .horizontal: return horizontalCompressResistance
        case .vertical: return verticalCompressResistance
        }
    }

    /// Sets the content hugging priority of this view on a given orientation.
    ///
    /// Content hugging priority adds a maximal size constraint when the
    /// view has a non-nil `intrinsicSize`.
    ///
    /// If `nil` is provided as a priority, it indicates the view makes no attempt
    /// at ensuring that its size at the specified orientation be at most as
    /// large as its `intrinsicSize` property.
    public func setContentHuggingPriority(_ orientation: LayoutAnchorOrientation,
                                          _ priority: LayoutPriority?) {
        switch orientation {
        case .horizontal: horizontalHuggingPriority = priority
        case .vertical: verticalHuggingPriority = priority
        }
    }

    /// Gets the content hugging priority of this view on a given orientation.
    public func contentHuggingPriority(_ orientation: LayoutAnchorOrientation) -> LayoutPriority? {
        switch orientation {
        case .horizontal: return horizontalHuggingPriority
        case .vertical: return verticalHuggingPriority
        }
    }

    func locationAffectsConstraints() -> Bool {
        areaIntoConstraintsMask.contains(.location)
    }

    func sizeAffectsConstraints() -> Bool {
        areaIntoConstraintsMask.contains(.size)
    }

    // MARK: LayoutVariablesContainer implementations
    // NOTE: adding the methods here instead of extension bellow to allow overriding.

    func didAddConstraint(_ constraint: LayoutConstraint) {

    }

    func didRemoveConstraint(_ constraint: LayoutConstraint) {

    }

    // MARK: - Descendent Checking / Hierarchy

    /// Returns `true` iff `self` is a non-strict descendant of `view` (i.e. is
    /// the view itself, a subview, or a subview-of-a-subview etc. of `view`).
    ///
    /// In case `self === view`, `true` is returned.
    open func isDescendant(of view: View) -> Bool {
        var parent: View? = self
        while let p = parent {
            if p === view {
                return true
            }
            parent = p.superview
        }

        return false
    }

    func visitingSuperviews(_ visitor: (View) -> Void) {
        var view: View? = self
        while let v = view {
            visitor(v)
            view = v.superview
        }
    }

    /// Returns the first common ancestor between `view1` and `view2`.
    ///
    /// If the common ancestor between the views is either `view1` or `view2`,
    /// that ancestor view is returned.
    ///
    /// If no common ancestor exists for the two views, `nil` is returned, instead.
    ///
    /// If both views refer to the same view, that view is returned.
    static func firstCommonAncestor(between view1: View, _ view2: View) -> View? {
        if view1 === view2 {
            return view1
        }

        var parent: View? = view1
        while let p = parent {
            if view2.isDescendant(of: p) {
                return p
            }

            parent = p.superview
        }

        return nil
    }

    /// Specifies intrinsic size for a view.
    public enum IntrinsicSize: Hashable {
        /// No intrinsic size.
        case none

        /// A width-only intrinsic size.
        case width(Double)

        /// A height-only intrinsic size.
        case height(Double)

        /// A width/height intrinsic size.
        case size(UISize)

        /// Gets the width of this intrinsic size, if present.
        public var width: Double? {
            switch self {
            case .width(let value):
                return value

            case .size(let size):
                return size.width

            case .none, .height:
                return nil
            }
        }

        /// Gets the height of this intrinsic size, if present.
        public var height: Double? {
            switch self {
            case .height(let value):
                return value

            case .size(let size):
                return size.height

            case .none, .width:
                return nil
            }
        }
    }
}

extension View: Equatable {
    /// Returns `true` if the two given view references are pointing to the same
    /// view instance.
    public static func == (lhs: View, rhs: View) -> Bool {
        return lhs === rhs
    }
}

extension View: Hashable {
    /// Hashes this view as an identity hash, i.e. based on its pointer value.
    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}

extension View: SpatialReferenceType {

}

extension View: LayoutVariablesContainer {
    var parent: LayoutVariablesContainer? {
        return superview
    }
    var viewInHierarchy: View? {
        return self
    }

    func hasConstraintsOnAnchorKind(_ anchorKind: AnchorKind) -> Bool {
        constraints.contains { ($0.firstCast._owner === self && $0.firstCast.kind == anchorKind) || ($0.secondCast?._owner === self && $0.secondCast?.kind == anchorKind) }
    }

    func constraintsOnAnchorKind(_ anchorKind: AnchorKind) -> [LayoutConstraint] {
        constraints.filter { ($0.firstCast._owner === self && $0.firstCast.kind == anchorKind) || ($0.secondCast?._owner === self && $0.secondCast?.kind == anchorKind) }
    }

    func setAreaSkippingLayout(_ area: UIRectangle) {
        _skipSetNeedsLayoutOnBounds = true
        self.area = area
        _skipSetNeedsLayoutOnBounds = false
    }
}

/// Used by `View` objects to specify which dimensions it should turn into
/// constraints implicitly in the constraint system.
public enum BoundsConstraintMask: CaseIterable {
    /// Specifies that the location of a view be treated as a set of constraints
    /// that must be respected during constraint resolution.
    case location

    /// Specifies that the size of a view be treated as a set of constraints that
    /// must be respected during constraint resolution.
    case size
}

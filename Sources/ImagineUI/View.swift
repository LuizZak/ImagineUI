import Foundation
import SwiftBlend2D

open class View {
    /// Whether the layout variables produced by this container should have a
    /// forced intrinsic size of zero. Used by View's methods that calculate
    /// minimal content sizes
    internal var _targetLayoutSize: Size? = nil
    
    var horizontalCompressResistance: LayoutPriority = 750
    var verticalCompressResistance: LayoutPriority = 750
    var horizontalHuggingPriority: LayoutPriority = 150
    var verticalHuggingPriority: LayoutPriority = 150
    var layoutVariables: LayoutVariables!
    
    var isLayoutSuspended = false
    
    var rootView: RootView? {
        if let rootView = self as? RootView {
            return rootView
        }
        
        return superview?.rootView
    }

    public internal(set) var needsLayout: Bool = true

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
    
    open var scale: Vector2 = Vector2(x: 1, y: 1) {
        willSet {
            guard scale != newValue else { return }
            
            invalidate()
        }
        didSet {
            guard scale != oldValue else { return }
            
            invalidate()
        }
    }
    
    open var clipToBounds: Bool = true {
        didSet {
            guard clipToBounds != oldValue else { return }
            
            invalidate()
        }
    }

    open var transform: Matrix2D {
        return Matrix2D.transformation(xScale: scale.x, yScale: scale.y,
                                       angle: rotation,
                                       xOffset: location.x, yOffset: location.y)
    }

    public var location: Vector2 {
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

            if areaIntoConstraintsMask.contains(.location) {
                setNeedsLayout()
            }
        }
    }

    open var bounds: Rectangle {
        willSet {
            if bounds != newValue {
                invalidate()
            }
        }
        didSet {
            bounds = Rectangle(left: 0, top: 0, right: bounds.width, bottom: bounds.height)
            if bounds == oldValue {
                return
            }
            
            invalidate()

            if areaIntoConstraintsMask.contains(.size) {
                setNeedsLayout()
            }
        }
    }
    
    open var size: Size {
        get {
            return bounds.size
        }
        set {
            bounds.size = newValue
        }
    }

    open var area: Rectangle {
        get {
            return Rectangle(x: location.x, y: location.y, width: bounds.width, height: bounds.height)
        }
        set {
            location = newValue.location
            bounds.size = newValue.size
        }
    }

    open var isVisible: Bool = true {
        didSet {
            if isVisible == oldValue { return }
            
            invalidate()
        }
    }

    // MARK: -

    /// A list of constraints that affect this view, or other subviews in the
    /// same hierarchy.
    /// Should be unique between all constraints created across the view hierarchy.
    internal var containedConstraints: [LayoutConstraint] = []

    /// A list of constraints that are affecting this view.
    internal(set) public var constraints: [LayoutConstraint] = []

    public var intrinsicSize: Size? {
        return nil
    }

    private(set) public weak var superview: View?

    private(set) public var subviews: [View] = []
    private(set) public var layoutGuides: [LayoutGuide] = []
    public var areaIntoConstraintsMask: Set<BoundsConstraintMask> = [.location, .size] {
        didSet {
            setNeedsLayout()
        }
    }

    public var isInteractiveEnabled: Bool = true

    /// Gets the active control system for the view hierarchy.
    /// Used to handle first responder configurations.
    public var controlSystem: ControlSystem? {
        return superview?.controlSystem
    }

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

    public final func renderRecursive(in context: BLContext, screenRegion: BLRegion) {
        if !isVisible {
            return
        }
        // TODO: Re-enable fully once Blend2D supports polygon clipping.
        // Currently, clipping is subtractive over rectangles, but redraw regions
        // can be a series of rectangles overlapping one another producing a
        // polygon-like clipping area
        //
        // For now, clipping region is merged at sample app before rendering, so
        // it is guaranteed the clipping region is a single box.
        if screenRegion.hitTest(BLBoxI(roundingRect: boundsForRedrawOnScreen().asBLRect)) == .out {
            return
        }

        let cookie = context.saveWithCookie()

        context.transform(transform.asBLMatrix2D)
        if clipToBounds {
            context.clipToRect(boundsForRedraw().asBLRect)
        }

        render(in: context, screenRegion: screenRegion)

        for view in subviews {
            view.renderRecursive(in: context, screenRegion: screenRegion)
        }

        context.restore(from: cookie)
    }

    open func render(in context: BLContext, screenRegion: BLRegion) {

    }

    // MARK: - Layout
    open func setupHierarchy() {

    }

    open func setupConstraints() {

    }

    open func performLayout() {
        if !needsLayout {
            return
        }
        
        /// If no superview is available, perform constraint layout locally,
        /// instead
        if superview == nil {
            performConstraintsLayout()
        }

        needsLayout = false

        for subview in subviews {
            subview.performLayout()
        }
    }
    
    internal func performConstraintsLayout() {
        let solver = LayoutConstraintSolver()
        solver.solve(viewHierarchy: self, cache: nil)
    }
    
    /// Suspends setNeedsLayout() from affecting this view and its parent
    /// hierarchy
    open func suspendLayout() {
        isLayoutSuspended = true
    }
    
    /// Resumes layout, optionally dispatching a message to layout the view
    open func resumeLayout(setNeedsLayout: Bool) {
        isLayoutSuspended = false
        
        if setNeedsLayout {
            self.setNeedsLayout()
        }
    }

    open func setNeedsLayout() {
        if isLayoutSuspended {
            return
        }
        
        superview?.setNeedsLayout()
        needsLayout = true
    }
    
    /// Calculates the optimal size for this view, taking in consideration its
    /// active constraints, while approaching the target size as much as possible.
    /// The layout of the view is kept as-is, and no changes to its size are made.
    open func layoutSizeFitting(size: Size) -> Size {
        // Store state for later restoring
        let previousSuperview = superview
        let previousNeedsLayout = needsLayout
        let snapshot = LayoutAreaSnapshot.snapshotHierarchy(self)
        
        // Remove view from hierarchy to avoid propagating invalidations
        superview = nil
        
        _targetLayoutSize = size
        performConstraintsLayout()
        
        let optimalSize = self.size
        
        // Restore views back to previous state
        snapshot.restore()
        _targetLayoutSize = nil
        needsLayout = previousNeedsLayout
        superview = previousSuperview
        
        return optimalSize
    }

    // MARK: - Subviews

    open func addSubview(_ view: View) {
        if view.superview != nil {
            view.removeFromSuperview()
        }

        setNeedsLayout()
        view.superview = self
        subviews.append(view)

        superview?.setNeedsLayout()
        view.invalidate()
        
        didAddSubview(view)
    }
    
    /// Function called after a view has been added as a subview of this view
    open func didAddSubview(_ view: View) {
        
    }
    
    /// Function called before a view is removed as a subview of this view instance
    open func willRemoveSubview(_ view: View) {
        
    }

    open func removeFromSuperview() {
        invalidate()
        
        if let superview = superview {
            superview.willRemoveSubview(self)
        }

        // Remove all constraints that involve this view, or one of its subviews.
        // We check parent views only because the way containedConstraints are
        // stored, each constraint is guaranteed to only affect the view itself
        // or one of its subviews, thus we check the parent hierarchy for
        // constraints involving this view tree, but not the children hierarchy.
        superview?.visitingSuperviews { view in
            for constraint in view.containedConstraints {
                if constraint.firstCast._owner?.viewInHierarchy?.isDescendant(of: self) == true {
                    constraint.removeConstraint()
                }
                if constraint.secondCast?._owner?.viewInHierarchy?.isDescendant(of: self) == true {
                    constraint.removeConstraint()
                }
            }
        }
        
        superview?.subviews.removeAll(where: { $0 === self })
        superview = nil
    }
    
    /// A method that should return the subview from this view hierarchy to which
    /// firstBaseline constraints should be attached to.
    ///
    /// If `nil`, the baseline is derived from this view's baseline.
    open func viewForFirstBaseline() -> View? {
        return nil
    }
    
    // MARK: - Layout Guides
    
    open func addLayoutGuide(_ guide: LayoutGuide) {
        if let previous = guide.owningView {
            previous.removeLayoutGuide(guide)
        }
        
        guide.owningView = self
        layoutGuides.append(guide)
    }
    
    open func removeLayoutGuide(_ guide: LayoutGuide) {
        if let index = layoutGuides.firstIndex(where: { $0 === guide }) {
            guide.owningView = nil
            layoutGuides.remove(at: index)
            
            for constraint in guide.constraints {
                constraint.removeConstraint()
            }
        }
    }

    // MARK: - Redraw Invalidation

    open func invalidate() {
        invalidate(bounds: boundsForRedraw())
    }

    open func invalidate(bounds: Rectangle) {
        var bounds = bounds
        if clipToBounds {
            bounds = bounds.formIntersection(self.boundsForRedraw())
        }
        if bounds.width == 0 || bounds.height == 0 {
            return
        }
        
        invalidate(bounds: bounds, spatialReference: self)
    }
    
    internal func invalidate(bounds: Rectangle, spatialReference: SpatialReferenceType) {
        superview?.invalidate(bounds: bounds, spatialReference: spatialReference)
    }

    func boundsForRedraw() -> Rectangle {
        return bounds
    }

    /// Returns the bounds for redrawing on the superview's coordinate system
    func boundsForRedrawOnSuperview() -> Rectangle {
        return transform.transform(boundsForRedraw())
    }

    /// Returns the bounds for redrawing on the screen's coordinate system
    func boundsForRedrawOnScreen() -> Rectangle {
        return absoluteTransform().transform(boundsForRedraw())
    }

    // MARK: - Transformation and Conversion

    open func absoluteTransform() -> Matrix2D {
        var transform = self.transform
        if let superview = superview {
            transform = transform * superview.absoluteTransform()
        }
        return transform
    }

    open func convert(point: Vector2, to other: SpatialReferenceType?) -> Vector2 {
        var point = point
        point *= absoluteTransform()
        if let other = other {
            point *= other.absoluteTransform().inverted()
        }
        return point
    }

    open func convert(point: Vector2, from other: SpatialReferenceType?) -> Vector2 {
        var point = point
        if let other = other {
            point *= other.absoluteTransform()
        }
        point *= absoluteTransform().inverted()

        return point
    }

    open func convert(bounds: Rectangle, to other: SpatialReferenceType?) -> Rectangle {
        var bounds = bounds
        bounds = absoluteTransform().transform(bounds)
        if let other = other {
            bounds = other.absoluteTransform().inverted().transform(bounds)
        }
        return bounds
    }

    open func convert(bounds: Rectangle, from other: SpatialReferenceType?) -> Rectangle {
        var bounds = bounds
        if let other = other {
            bounds = other.absoluteTransform().transform(bounds)
        }
        bounds = absoluteTransform().inverted().transform(bounds)
        return bounds
    }

    open func convertFromScreen(_ point: Vector2) -> Vector2 {
        return convert(point: point, from: nil)
    }

    // MARK: - Bounds / Hit testing

    /// Performs a hit test operation on the area of this, and all child base
    /// views, for the given absolute coordinates point.
    ///
    /// Returns the first base view that crosses the point.
    ///
    /// The `inflatingArea` argument can be used to inflate the area of the
    /// views to perform less precise hit tests.
    public func viewUnder(point: Vector2, inflatingArea: Vector2 = .zero) -> View? {
        guard contains(point: point, inflatingArea: inflatingArea) else {
            return nil
        }
        
        // Search children first
        for baseView in subviews.reversed() {
            if let ht = baseView.viewUnder(point: baseView.transform.inverted().transform(point),
                                           inflatingArea: inflatingArea) {
                return ht
            }
        }

        return self
    }

    /// Performs a hit test operation on the area of this, and all child base
    /// views, for the given absolute coordinates point.
    ///
    /// Returns the first base view that crosses the point and returns true for
    /// `predicate`.
    ///
    /// The `inflatingArea` argument can be used to inflate the area of the views
    /// to perform less precise hit tests.
    public func viewUnder(point: Vector2, inflatingArea: Vector2 = .zero, predicate: (View) -> Bool) -> View? {
        guard contains(point: point, inflatingArea: inflatingArea) else {
            return nil
        }
        
        // Search children first
        for baseView in subviews.reversed() {
            if let ht = baseView.viewUnder(point: baseView.transform.inverted().transform(point),
                                           inflatingArea: inflatingArea,
                                           predicate: predicate) {
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
    /// - Parameter point: Point to test
    /// - Parameter inflatingArea: Used to inflate the area of the views to
    /// perform less precise hit tests.
    /// - Returns: An array where each view returned crosses the given point.
    public func viewsUnder(point: Vector2, inflatingArea: Vector2 = .zero) -> [View] {
        var views: [View] = []

        internalViewsUnder(point: point, inflatingArea, &views)

        return views
    }

    private func internalViewsUnder(point: Vector2, _ inflatingArea: Vector2, _ target: inout [View]) {
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

    /// Returns an enumerable of all views that cross the given `BLRect` bounds.
    ///
    /// The `inflatingArea` argument can be used to inflate the area of the views
    /// to perform less precise hit tests.
    ///
    /// The `BLRect` is converted into local bounds for each subview, so distortion
    /// may occur and result in inaccurate results for views that are rotated.
    /// There are no alternatives for this, currently.
    ///
    /// - Parameter point: BLRect to test
    /// - Parameter inflatingArea: Used to inflate the area of the views to perform
    /// less precise hit tests.
    /// - Returns: An enumerable where each view returned intersects the given
    /// `BLRect`
    public func viewsUnder(area: Rectangle, inflatingArea: Vector2 = .zero) -> [View] {
        var views: [View] = []

        internalViewsUnder(area: area, inflatingArea, &views)

        return views
    }

    private func internalViewsUnder(area: Rectangle, _ inflatingArea: Vector2, _ target: inout [View]) {
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
    public func contains(point: Vector2, inflatingArea: Vector2 = .zero) -> Bool {
        if inflatingArea == .zero {
            return bounds.contains(point)
        }
        
        return bounds.insetBy(x: -inflatingArea.x, y: -inflatingArea.y).contains(point)
    }

    /// Returns true if the given `BLRect` intersects this view's area when
    /// inflated by a specified amount.
    ///
    /// Children views' bounds do not affect the hit test- it happens only on
    /// this view's `bounds` area.
    ///
    /// - Parameter area: area to test
    /// - Parameter inflatingArea: Used to inflate the area of the view to
    /// perform less precise hit tests.
    public func intersects(area: Rectangle, inflatingArea: Vector2 = .zero) -> Bool {
        return bounds.insetBy(x: -inflatingArea.x, y: -inflatingArea.y).intersects(area)
    }
    
    // MARK: - Content Compression/Hugging configuration
    
    public func setContentCompressionResistance(_ orientation: LayoutAnchorOrientation,
                                                _ priority: LayoutPriority) {
        setNeedsLayout()
        
        switch orientation {
        case .horizontal: horizontalCompressResistance = priority
        case .vertical: verticalCompressResistance = priority
        }
    }
    
    public func contentCompressionResistance(_ orientation: LayoutAnchorOrientation) -> LayoutPriority {
        switch orientation {
        case .horizontal: return horizontalCompressResistance
        case .vertical: return verticalCompressResistance
        }
    }
    
    public func setContentHuggingPriority(_ orientation: LayoutAnchorOrientation,
                                          _ priority: LayoutPriority) {
        setNeedsLayout()
        
        switch orientation {
        case .horizontal: horizontalHuggingPriority = priority
        case .vertical: verticalHuggingPriority = priority
        }
    }
    
    public func contentHuggingPriority(_ orientation: LayoutAnchorOrientation) -> LayoutPriority {
        switch orientation {
        case .horizontal: return horizontalHuggingPriority
        case .vertical: return verticalHuggingPriority
        }
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
}

extension View: SpatialReferenceType {
    
}

extension View: LayoutVariablesContainer {
    var parent: SpatialReferenceType? {
        return superview
    }
    var viewInHierarchy: View? {
        return self
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
    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}

public enum BoundsConstraintMask {
    case location
    case size
}

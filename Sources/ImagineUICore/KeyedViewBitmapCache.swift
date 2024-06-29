/// A specialization of `ViewBitmapCache` that supports storing hashable metadata
/// that can be used to invalidate the contents of the cache by comparing the
/// current values with the values present the previous time the cache was rendered.
public class KeyedViewBitmapCache: ViewBitmapCache {
    private var _lastRenderedKey: Key?
    private var _incomingKey: Key?

    /// Updates the key for this bitmap cache to be a ordered-set of the given
    /// hashable values.
    ///
    /// The next time `cachingOrRendering` is invoked, if the contents of the
    /// latest `updateKeys` up to before the method is invoked is different from
    /// the contents of the last time `cachingOrRendering` was invoked, the bitmap
    /// cache is invalidated and is re-rendered.
    public func updateKeys(_ keys: AnyHashable...) {
        _incomingKey = .init(keys: keys)
    }

    /// Performs a deferred rendering operation that either redraws the cache
    /// bitmap if it's been invalidated through `closure` and then draws it on
    /// `renderer`, or if a cached bitmap is already present, draws the cached
    /// bitmap to `renderer` and skips invoking `closure`.
    ///
    /// If the latest `updateKeys` invocation does not match the keys present
    /// when the last `cachingOrRendering` call was made, the contents of the
    /// cache are erased and re-rendered.
    public override func cachingOrRendering(
        _ renderer: any Renderer,
        _ closure: (any Renderer) -> Void
    ) {
        if _incomingKey != _lastRenderedKey {
            invalidateCache()
            _lastRenderedKey = _incomingKey
        }

        super.cachingOrRendering(renderer, closure)
    }

    private struct Key: Hashable {
        var keys: [AnyHashable]
    }
}

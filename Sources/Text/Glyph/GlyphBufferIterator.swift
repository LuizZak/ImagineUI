/// A helper to iterate over a `GlyphBuffer`.
///
/// Example:
///
/// ```
/// func inspectGlyphBuffer(_ glyphBuffer: GlyphBuffer) {
///     var it = glyphBuffer.makeIterator()
///     if it.hasPlacement {
///         while !it.atEnd {
///             guard let glyphId = it.glyphId,
///                   let offset = it.advanceOffset else {
///                 continue
///             }
///
///             // Do something with `glyphId` and `offset`.
///
///             it.advance()
///         }
///     } else {
///         while !it.atEnd {
///             guard let glyphId = it.glyphId else {
///                 continue
///             }
///
///             // Do something with `glyphId`.
///
///             it.advance()
///         }
///     }
/// }
/// ```
public protocol GlyphBufferIterator {
    var index: Int { get }
    var atEnd: Bool { get }
    var hasPlacement: Bool { get }
    
    var glyphId: UInt32? { get }
    var advanceOffset: GlyphPlacement? { get }
    
    mutating func advance()
}

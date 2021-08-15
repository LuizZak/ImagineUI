import Geometry

public protocol GlyphBuffer {
    func makeIterator() -> GlyphBufferIterator
}

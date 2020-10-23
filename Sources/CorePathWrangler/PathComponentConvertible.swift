/// The type of a path component (e.g. 'home' and 'user' in '/home/user').
public typealias PathComponent = String

/// A type that can convert itself into a path component.
public protocol PathComponentConvertible {
    /// The path component of the conforming type.
    var pathComponent: PathComponent { get }
}

extension String: PathComponentConvertible {
    /// See `PathComponentConvertible.pathComponent`
    @inlinable
    public var pathComponent: PathComponent { self }
}

extension StaticString: PathComponentConvertible {
    /// See `PathComponentConvertible.pathComponent`
    public var pathComponent: PathComponent {
        hasPointerRepresentation ? String(cString: utf8Start) : String(unicodeScalar)
    }
}

extension BinaryInteger where Self: PathComponentConvertible {
    /// See `PathComponentConvertible.pathComponent`
    @inlinable
    public var pathComponent: PathComponent { String(self) }
}

extension FloatingPoint where Self: LosslessStringConvertible, Self: PathComponentConvertible {
    /// See `PathComponentConvertible.pathComponent`
    @inlinable
    public var pathComponent: PathComponent { String(self) }
}

extension Int: PathComponentConvertible {}
extension Int8: PathComponentConvertible {}
extension Int16: PathComponentConvertible {}
extension Int32: PathComponentConvertible {}
extension Int64: PathComponentConvertible {}

extension UInt: PathComponentConvertible {}
extension UInt8: PathComponentConvertible {}
extension UInt16: PathComponentConvertible {}
extension UInt32: PathComponentConvertible {}
extension UInt64: PathComponentConvertible {}

extension Float: PathComponentConvertible {}
extension Double: PathComponentConvertible {}

extension RawRepresentable where RawValue: PathComponentConvertible, Self: PathComponentConvertible {
    /// See `PathComponentConvertible.pathComponent`
    @inlinable
    public var pathComponent: PathComponent { rawValue.pathComponent }
}

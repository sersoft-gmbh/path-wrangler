/// The type of a path component (e.g. 'home' and 'user' in '/home/user').
public typealias PathComponent = String

/// A type that can convert itself into a path component.
public protocol PathComponentConvertible {
    /// The path component of the conforming type.
    var pathComponent: PathComponent { get }
}

extension String: PathComponentConvertible {
    @inlinable
    public var pathComponent: PathComponent { self }
}

extension StaticString: PathComponentConvertible {
    public var pathComponent: PathComponent {
        hasPointerRepresentation ? String(cString: utf8Start) : String(unicodeScalar)
    }
}

extension BinaryInteger where Self: PathComponentConvertible {
    @inlinable
    public var pathComponent: PathComponent { String(self) }
}

extension FloatingPoint where Self: LosslessStringConvertible, Self: PathComponentConvertible {
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
    @inlinable
    public var pathComponent: PathComponent { rawValue.pathComponent }
}

/// The type of a path extension (e.g. 'txt' of 'file.txt').
public typealias PathExtension = String

/// A generic protocol around a path. Currently, there are two conformances, `AbsolutePath` and `RelativePath`.
/// It is strongly discouraged to declare new conformances to this protocol. They're not guaranteed to work as expected.
public protocol PathProtocol: Hashable {
    /// The string reprensentation of the path this conformance represents.
    var pathString: String { get }

    /// The last component of this path.
    var lastPathComponent: PathComponent? { get }
    /// The extension of the last component of this path.
    var lastPathExtension: PathExtension? { get }

    /// Creates a new path by parsing the given string.
    /// - Parameter pathString: The path string to parse into a path.
    init(pathString: String)

    /// Returns the current path.
    static var current: Self { get }

    /// Checks whether the receiver is a sub-path of the given absolute path.
    /// - Parameter other: The absolute path, which should be checked for being a parent path of the receiver.
    func isSubpath(of other: AbsolutePath) -> Bool
    /// Checks whether the receiver is a sub-path of the given relative path.
    /// - Parameter other: The relative path, which should be checked for being a parent path of the receiver.
    func isSubpath(of other: RelativePath) -> Bool

    /// Appends a relative path to the receiver.
    /// - Parameter other: The relative path to append to the receiver.
    mutating func append(_ other: RelativePath)
    /// Returns a new path which has `other` appended to the receiver.
    /// - Parameter other: The relative path to append to the reciever.
    func appending(_ other: RelativePath) -> Self

    /// Appends the path components, taken from each element of the sequence of path component convertible objects, to the receiver.
    /// - Parameter pathComponents: The sequence of path component convertible objects, whose path components to append to the receiver.
    mutating func append<Components>(pathComponents: Components)
    where Components: Sequence, Components.Element == PathComponentConvertible
    /// Returns a new path by appending the path components, taken from each element of the sequence of path component convertible objects, to the receiver.
    /// - Parameter pathComponents: The sequence of path component convertible objects, whose path components to append to the receiver and return.
    func appending<Components>(pathComponents: Components) -> Self
    where Components: Sequence, Components.Element == PathComponentConvertible

    /// Appends a path extension to the last component of the receiver.
    /// - Parameter pathExtension: The extension to append to the last component of the receiver.
    /// - Note: If the path has no components, this method does nothing.
    mutating func append(pathExtension: PathExtension)
    /// Returns a new path by appending the given path extension the last component of the receiver.
    /// - Parameter pathExtension: The extension to append to the last component of the receiver.
    /// - Note: If the path has no components, this method returns the unchanged receiver.
    func appending(pathExtension: PathExtension) -> Self

    /// Removes the last path component of the reciever.
    mutating func removeLastPathComponent()
    /// Returns a new path which has the last path component of the receiver removed.
    func removingLastPathComponent() -> Self

    /// Removes the last extension of the last component of the receiver.
    mutating func removeLastPathExtension()
    /// Returns a new path that has the last extension from the last component of the receiver removed.
    func removingLastPathExtension() -> Self
}

extension PathProtocol where Self: CustomStringConvertible {
    /// See `CustomStringConvertible.description`
    @inlinable
    public var description: String { pathString }
}

extension PathProtocol where Self: LosslessStringConvertible {
    /// See `LosslessStringConvertible.init(_:)`
    /// - Parameter description: See `LosslessStringConvertible.init(_:)`
    @inlinable
    public init?(_ description: String) {
        self.init(pathString: description)
    }
}

extension PathProtocol where Self: CustomDebugStringConvertible {
    /// See `CustomDebugStringConvertible.debugDescription`
    public var debugDescription: String { "[\(Self.self)]: \(pathString)" }
}

extension PathProtocol {
    /// Appends the path components, taken from each element of the variadic list of path component convertible objects, to the receiver.
    /// - Parameter pathComponents: The variadic list of path component convertible objects, whose path components to append to the receiver.
    @inlinable
    public mutating func append(pathComponents: PathComponentConvertible...) {
        append(pathComponents: pathComponents)
    }

    /// Returns a new path by appending the path components, taken from each element of the variadic list of path component convertible objects, to the receiver.
    /// - Parameter pathComponents: The variadic list of path component convertible objects, whose path components to append to the receiver and return.
    @inlinable
    public func appending(pathComponents: PathComponentConvertible...) -> Self {
        appending(pathComponents: pathComponents)
    }
}

extension PathProtocol {
    /// Conveniently forms a path by appending the path component of a path component convertible object to an existing path.
    /// - Parameters:
    ///   - lhs: The existing path to append the path component to.
    ///   - rhs: The path component convertible object to append the path component to.
    @inlinable
    public static func / <Component: PathComponentConvertible> (lhs: Self, rhs: Component) -> Self {
        lhs.appending(pathComponents: rhs)
    }
}

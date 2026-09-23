public import CorePathWrangler
public import Foundation

extension PathProtocol {
    /// Creates a new path from the given URL. Returns nil if the url is not a file url.
    /// - Parameter url: The url to create the path from.
    public init?(url: URL) {
        guard url.isFileURL else { return nil }
        self.init(pathString: url.path)
    }
}

extension URL {
    /// Creates a file url from the given path, by also specifying whether it points to a directory or not.
    /// - Parameters:
    ///   - path: The path to create the file url for.
    ///   - isDirectory: Whether or not `path` points to a directory.
    /// - SeeAlso: ``Foundation/URL/init(fileURLWithPath:isDirectory:)``
    @inlinable
    public init(path: some PathProtocol, isDirectory: Bool) {
        if #available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *) {
            self.init(filePath: path.pathString, directoryHint: isDirectory ? .isDirectory : .notDirectory)
        } else {
            self.init(fileURLWithPath: path.pathString, isDirectory: isDirectory)
        }
    }

    /// Creates a file url from the given path.
    /// - Parameter path: The path to create the file url for.
    /// - SeeAlso: ``Foundation/URL/init(fileURLWithPath:)``
    @inlinable
    public init(path: some PathProtocol) {
        if #available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *) {
            self.init(filePath: path.pathString)
        } else {
            self.init(fileURLWithPath: path.pathString)
        }
    }

    @inlinable
    mutating func _append(pathComponent: some StringProtocol) {
        if #available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *) {
            append(path: pathComponent)
        } else {
            appendPathComponent(String(pathComponent))
        }
    }

    /// Appends the path components, taken from each element of the sequence of path component convertible objects, to the receiver.
    /// - Parameter pathComponents: The sequence of path component convertible objects, whose path components to append to the receiver.
    /// - SeeAlso: ``appendPathComponent(_:)``
    @inlinable
    public mutating func append(pathComponents: some Sequence<any PathComponentConvertible>) {
        for component in pathComponents {
            _append(pathComponent: component.pathComponent)
        }
    }

    /// Appends the path components, taken from each element of the variadic list of path component convertible objects, to the receiver.
    /// - Parameter pathComponents: The variadic list of path component convertible objects, whose path components to append to the receiver.
    /// - SeeAlso: ``appendPathComponent(_:)``
    @inlinable
    @_disfavoredOverload
    public mutating func append(pathComponents: any PathComponentConvertible...) {
        append(pathComponents: pathComponents)
    }

    /// Appends the path component of the path component convertible object to the receiver.
    /// - Parameter pathComponent: The path component convertible object, whose path component to append to the receiver.
    @inlinable
    public mutating func append(pathComponent: borrowing some PathComponentConvertible & ~Copyable & ~Escapable) {
        _append(pathComponent: pathComponent.pathComponent)
    }

    /// Appends the path components, taken from each element of the sequence of path component convertible objects, to the receiver.
    /// - Parameter pathComponents: The sequence of path component convertible objects, whose path components to append to the receiver.
    @inlinable
    public mutating func append<each Component: PathComponentConvertible>(pathComponents: repeat each Component) {
        for component in repeat each pathComponents {
            append(pathComponent: component)
        }
    }

    /// Returns a new path by appending the path components, taken from each element of the sequence of path component convertible objects, to the receiver.
    /// - Parameter pathComponents: The sequence of path component convertible objects, whose path components to append to the receiver and return.
    /// - SeeAlso: ``appendingPathComponent(_:)``
    @inlinable
    public func appending(pathComponents: some Sequence<any PathComponentConvertible>) -> URL {
        pathComponents.reduce(into: self) { $0._append(pathComponent: $1.pathComponent) }
    }

    /// Returns a new path by appending the path components, taken from each element of the variadic list of path component convertible objects, to the receiver.
    /// - Parameter pathComponents: The variadic list of path component convertible objects, whose path components to append to the receiver and return.
    /// - SeeAlso: ``appendingPathComponent(_:)``
    @inlinable
    @_disfavoredOverload
    public mutating func appending(pathComponents: any PathComponentConvertible...) -> URL {
        appending(pathComponents: pathComponents)
    }

    /// Returns a new path by appending the path components, taken from each element of the sequence of path component convertible objects, to the receiver.
    /// - Parameter pathComponents: The sequence of path component convertible objects, whose path components to append to the receiver and return.
    @inlinable
    public func appending<each Component: PathComponentConvertible>(pathComponents: repeat each Component) -> Self {
        var newSelf = self
        newSelf.append(pathComponents: repeat each pathComponents)
        return newSelf
    }

    /// Returns a new path by appending the path component taken from the path component convertible object to the receiver.
    /// - Parameter pathComponents: The path component convertible object, whose path component to append to the receiver and return.
    @inlinable
    public func appending(pathComponent: borrowing some PathComponentConvertible & ~Copyable & ~Escapable) -> Self {
        var newSelf = self
        newSelf.append(pathComponent: pathComponent)
        return newSelf
    }

    /// Checks whether the receiver is a sub-path of the given absolute path.
    /// - Parameter other: The absolute path, which should be checked for being a parent path of the receiver.
    @inlinable
    public func isSubpath(of other: AbsolutePath) -> Bool {
        AbsolutePath(url: self)?.isSubpath(of: other) == true
    }

    /// Checks whether the receiver is a sub-path of the given relative path.
    /// - Parameter other: The relative path, which should be checked for being a parent path of the receiver.
    @inlinable
    public func isSubpath(of other: RelativePath) -> Bool {
        RelativePath(url: self)?.isSubpath(of: other) == true
    }
}

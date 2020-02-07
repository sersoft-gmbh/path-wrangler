import CorePathWrangler
import Foundation

extension PathProtocol {
    public init?(url: URL) {
        guard url.isFileURL else { return nil }
        self.init(pathString: url.path)
    }
}

extension URL: PathProtocol {
    @inlinable
    public var pathString: String { path }

    @inlinable
    public var lastPathComponent: PathComponent? { pathComponents.last }

    @inlinable
    public var lastPathExtension: PathExtension? { pathExtension }

    @inlinable
    public init(pathString: String) {
        self.init(fileURLWithPath: pathString)
    }

    @inlinable
    public init() {
        self.init(fileURLWithPath: "/")
    }

    @inlinable
    public init<Path: PathProtocol>(path: Path) {
        self.init(fileURLWithPath: path.pathString)
    }

    @inlinable
    public init<Path: PathProtocol>(path: Path, isDirectory: Bool) {
        self.init(fileURLWithPath: path.pathString, isDirectory: isDirectory)
    }

    @inlinable
    public static var current: URL { URL(fileURLWithPath: FileManager.default.currentDirectoryPath) }

    @inlinable
    public mutating func append(_ other: RelativePath) {
        appendPathComponent(other.pathString)
    }

    @inlinable
    public func appending(_ other: RelativePath) -> URL {
        appendingPathComponent(other.pathString)
    }

    @inlinable
    public mutating func append<Components>(pathComponents: Components)
        where Components : Sequence, Components.Element == PathComponentConvertible
    {
        for component in pathComponents {
            appendPathComponent(component.pathComponent)
        }
    }

    @inlinable
    public func appending<Components>(pathComponents: Components) -> URL
        where Components : Sequence, Components.Element == PathComponentConvertible
    {
        pathComponents.reduce(into: self) { $0.appendPathComponent($1.pathComponent) }
    }

    @inlinable
    public mutating func append(pathExtension: PathExtension) {
        appendPathExtension(pathExtension)
    }

    @inlinable
    public func appending(pathExtension: PathExtension) -> URL {
        appendingPathExtension(pathExtension)
    }

    @inlinable
    public mutating func removeLastPathComponent() {
        deleteLastPathComponent()
    }

    @inlinable
    public func removingLastPathComponent() -> URL {
        deletingLastPathComponent()
    }

    @inlinable
    public mutating func removeLastPathExtension() {
        deletePathExtension()
    }

    @inlinable
    public func removingLastPathExtension() -> URL {
        deletingPathExtension()
    }

    @inlinable
    public func isSubpath(of other: AbsolutePath) -> Bool {
        RelativePath(url: self).map { other.isSubpath(of: $0) } == true
    }

    @inlinable
    public func isSubpath(of other: RelativePath) -> Bool {
        RelativePath(url: self).map { other.isSubpath(of: $0) } == true
    }
}

import CorePathWrangler
import Foundation

extension PathProtocol {
    public init?(url: URL) {
        guard url.isFileURL else { return nil }
        self.init(pathString: url.path)
    }
}

extension URL {
    @inlinable
    public init<Path: PathProtocol>(path: Path, isDirectory: Bool) {
        self.init(fileURLWithPath: path.pathString, isDirectory: isDirectory)
    }

    @inlinable
    public init<Path: PathProtocol>(path: Path) {
        self.init(fileURLWithPath: path.pathString)
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
    public mutating func append(pathComponents: PathComponentConvertible...) {
        append(pathComponents: pathComponents)
    }

    @inlinable
    public func appending<Components>(pathComponents: Components) -> URL
        where Components : Sequence, Components.Element == PathComponentConvertible
    {
        pathComponents.reduce(into: self) { $0.appendPathComponent($1.pathComponent) }
    }

    @inlinable
    public mutating func appending(pathComponents: PathComponentConvertible...) -> URL {
        appending(pathComponents: pathComponents)
    }

    @inlinable
    public func isSubpath(of other: AbsolutePath) -> Bool {
        AbsolutePath(url: self)?.isSubpath(of: other) == true
    }

    @inlinable
    public func isSubpath(of other: RelativePath) -> Bool {
        RelativePath(url: self)?.isSubpath(of: other) == true
    }
}

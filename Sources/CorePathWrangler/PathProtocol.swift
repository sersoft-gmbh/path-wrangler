public typealias PathExtension = String

public protocol PathProtocol: Hashable {
    var pathString: String { get }

    var lastPathComponent: PathComponent? { get }
    var lastPathExtension: PathExtension? { get }

    init(pathString: String)

    static var current: Self { get }

    func isSubpath(of other: AbsolutePath) -> Bool
    func isSubpath(of other: RelativePath) -> Bool

    mutating func append(_ other: RelativePath)
    func appending(_ other: RelativePath) -> Self

    mutating func append<Components>(pathComponents: Components) where Components: Sequence, Components.Element == PathComponentConvertible
    func appending<Components>(pathComponents: Components) -> Self where Components: Sequence, Components.Element == PathComponentConvertible

    mutating func append(pathExtension: PathExtension)
    func appending(pathExtension: PathExtension) -> Self

    mutating func removeLastPathComponent()
    func removingLastPathComponent() -> Self

    mutating func removeLastPathExtension()
    func removingLastPathExtension() -> Self
}

extension PathProtocol where Self: CustomStringConvertible {
    @inlinable
    public var description: String { pathString }
}

extension PathProtocol where Self: LosslessStringConvertible {
    @inlinable
    public init?(_ description: String) {
        self.init(pathString: description)
    }
}

extension PathProtocol where Self: CustomDebugStringConvertible {
    public var debugDescription: String { "[\(Self.self)]: \(pathString)" }
}

extension PathProtocol {
    @inlinable
    public mutating func append(pathComponents: PathComponentConvertible...) {
        append(pathComponents: pathComponents)
    }

    @inlinable
    public func appending(pathComponents: PathComponentConvertible...) -> Self {
        appending(pathComponents: pathComponents)
    }
}

extension PathProtocol {
    @inlinable
    public static func / <Component: PathComponentConvertible> (lhs: Self, rhs: Component) -> Self {
        lhs.appending(pathComponents: rhs)
    }
}

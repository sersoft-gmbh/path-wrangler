@usableFromInline
protocol _PathProtocol: PathProtocol, Sendable, Codable, CustomStringConvertible, CustomDebugStringConvertible {
    static var isAbsolute: Bool { get }

    var _impl: _PathImpl { get set }

    init(_impl: _PathImpl)

    func _isSubpath<Path: _PathProtocol>(of other: Path) -> Bool
}

extension _PathProtocol {
    @inlinable
    func _withCopiedImpl(do work: (inout _PathImpl) throws -> ()) rethrows -> Self {
        var newImpl = _impl
        try work(&newImpl)
        return Self(_impl: newImpl)
    }
}

extension _PathProtocol {
    @inlinable
    public var pathString: String { _impl.pathString }

    @inlinable
    public var lastPathComponent: PathComponent? { _impl.elements.last?.pathComponent }

    @inlinable
    public var lastPathExtension: PathExtension? { _impl.elements.last?.extensions.last }

    @inlinable
    init(elements: Array<PathElement>) {
        self.init(_impl: .init(isAbsolute: Self.isAbsolute, elements: elements))
    }

    @inlinable
    public init(pathString: String) {
        self.init(_impl: .init(isAbsolute: Self.isAbsolute, pathString: pathString))
    }

    @inlinable
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        try self.init(pathString: container.decode(String.self))
    }

    @inlinable
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(pathString)
    }

    @inlinable
    public static func ==(lhs: Self, rhs: Self) -> Bool {
        lhs._impl.elements == rhs._impl.elements
    }

    @inlinable
    public func hash(into hasher: inout Hasher) {
        hasher.combine(_impl.elements)
    }

    @inlinable
    public func isSubpath(of other: AbsolutePath) -> Bool {
        _isSubpath(of: other)
    }

    @inlinable
    public func isSubpath(of other: RelativePath) -> Bool {
        _isSubpath(of: other)
    }

    @inlinable
    public mutating func append(_ other: RelativePath) {
        guard !other._impl.elements.isEmpty else { return }
        _impl.elements.append(contentsOf: other._impl.elements)
    }

    @inlinable
    public func appending(_ other: RelativePath) -> Self {
        guard !other._impl.elements.isEmpty else { return self }
        return _withCopiedImpl {
            $0.elements.append(contentsOf: other._impl.elements)
        }
    }

    @inlinable
    public mutating func append<Components>(pathComponents: Components)
    where Components: Sequence, Components.Element == PathComponentConvertible
    {
        _impl.append(pathComponents: pathComponents)
    }

    @inlinable
    public func appending<Components>(pathComponents: Components) -> Self
    where Components: Sequence, Components.Element == PathComponentConvertible
    {
        _withCopiedImpl { $0.append(pathComponents: pathComponents) }
    }

    @inlinable
    public mutating func append(pathExtension: PathExtension) {
        guard !_impl.elements.isEmpty else { return }
        _impl.lastPathElement.append(pathExtension: pathExtension)
    }

    @inlinable
    public func appending(pathExtension: PathExtension) -> Self {
        guard !_impl.elements.isEmpty else { return self }
        return _withCopiedImpl {
            $0.lastPathElement.append(pathExtension: pathExtension)
        }
    }

    @inlinable
    public mutating func removeLastPathComponent() {
        guard !_impl.elements.isEmpty else { return }
        _impl.elements.removeLast()
    }

    @inlinable
    public func removingLastPathComponent() -> Self {
        guard !_impl.elements.isEmpty else { return self }
        return _withCopiedImpl { $0.elements.removeLast() }
    }

    @inlinable
    public mutating func removeLastPathExtension() {
        guard !_impl.elements.isEmpty && !_impl.lastPathElement.extensions.isEmpty else { return }
        _impl.lastPathElement.removeLastPathExtension()
    }

    @inlinable
    public func removingLastPathExtension() -> Self {
        guard !_impl.elements.isEmpty && !_impl.lastPathElement.extensions.isEmpty else { return self }
        return _withCopiedImpl { $0.lastPathElement.removeLastPathExtension() }
    }
}

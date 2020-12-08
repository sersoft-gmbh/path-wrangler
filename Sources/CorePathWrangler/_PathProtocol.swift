@usableFromInline
protocol _PathProtocol: PathProtocol, Codable, CustomStringConvertible, CustomDebugStringConvertible {
    static var isAbsolute: Bool { get }

    var storage: PathStorage { get }

    init(storage: PathStorage)

    mutating func copyStorageIfNeeded()

    func _isSubpath<Path: _PathProtocol>(of other: Path) -> Bool
}

extension _PathProtocol {
    @inlinable
    public var pathString: String { storage.pathString }

    @inlinable
    public var lastPathComponent: PathComponent? { storage.elements.last?.pathComponent }

    @inlinable
    public var lastPathExtension: PathExtension? { storage.elements.last?.extensions.last }

    @inlinable
    init(elements: [PathElement]) {
        self.init(storage: PathStorage(isAbsolute: Self.isAbsolute, elements: elements))
    }

    @inlinable
    public init(pathString: String) {
        self.init(storage: PathStorage(isAbsolute: Self.isAbsolute, pathString: pathString))
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
        lhs.storage.elements == rhs.storage.elements
    }

    @inlinable
    public func hash(into hasher: inout Hasher) {
        hasher.combine(storage.elements)
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
        guard !other.storage.elements.isEmpty else { return }
        copyStorageIfNeeded()
        storage.elements.append(contentsOf: other.storage.elements)
    }

    @inlinable
    public func appending(_ other: RelativePath) -> Self {
        guard !other.storage.elements.isEmpty else { return self }
        let newStorage = storage.copy()
        newStorage.elements.append(contentsOf: other.storage.elements)
        return Self(storage: newStorage)
    }

    @inlinable
    public mutating func append<Components>(pathComponents: Components)
    where Components: Sequence, Components.Element == PathComponentConvertible
    {
        copyStorageIfNeeded()
        storage.append(pathComponents: pathComponents)
    }

    @inlinable
    public func appending<Components>(pathComponents: Components) -> Self
    where Components: Sequence, Components.Element == PathComponentConvertible
    {
        let newStorage = storage.copy()
        newStorage.append(pathComponents: pathComponents)
        return Self(storage: newStorage)
    }

    @inlinable
    public mutating func append(pathExtension: PathExtension) {
        guard !storage.elements.isEmpty else { return }
        copyStorageIfNeeded()
        storage.lastPathElement.append(pathExtension: pathExtension)
    }

    @inlinable
    public func appending(pathExtension: PathExtension) -> Self {
        guard !storage.elements.isEmpty else { return self }
        let newStorage = storage.copy()
        newStorage.lastPathElement.append(pathExtension: pathExtension)
        return Self(storage: newStorage)
    }

    @inlinable
    public mutating func removeLastPathComponent() {
        guard !storage.elements.isEmpty else { return }
        copyStorageIfNeeded()
        storage.elements.removeLast()
    }

    @inlinable
    public func removingLastPathComponent() -> Self {
        guard !storage.elements.isEmpty else { return self }
        let newStorage = storage.copy()
        newStorage.elements.removeLast()
        return Self(storage: newStorage)
    }

    @inlinable
    public mutating func removeLastPathExtension() {
        guard !storage.elements.isEmpty && !storage.lastPathElement.extensions.isEmpty else { return }
        copyStorageIfNeeded()
        storage.lastPathElement.removeLastPathExtension()
    }

    @inlinable
    public func removingLastPathExtension() -> Self {
        guard !storage.elements.isEmpty && !storage.lastPathElement.extensions.isEmpty else { return self }
        let newStorage = storage.copy()
        newStorage.lastPathElement.removeLastPathExtension()
        return Self(storage: newStorage)
    }
}

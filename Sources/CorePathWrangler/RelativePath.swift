public struct RelativePath: _PathProtocol {
    @usableFromInline
    static let isAbsolute = false

    @usableFromInline
    private(set) var storage = PathStorage(isAbsolute: false)

    @usableFromInline
    init(storage: PathStorage) {
        assert(storage.isAbsolute == Self.isAbsolute)
        self.storage = storage
    }

    @usableFromInline
    mutating func copyStorageIfNeeded() {
        guard !isKnownUniquelyReferenced(&storage) else { return }
        storage = storage.copy()
    }

    @inlinable
    func _isSubpath<Path: _PathProtocol>(of other: Path) -> Bool {
        other.storage.elements.contains(storage.elements)
    }

    @inlinable
    public func absolute(in absolutePath: AbsolutePath) -> AbsolutePath {
        absolutePath.appending(self)
    }

    @inlinable
    public mutating func resolve() {
        guard !storage.elements.isEmpty else { return }
        copyStorageIfNeeded()
        storage.resolve(resolveSymlinks: false)
    }

    @inlinable
    public func resolved() -> Self {
        guard !storage.elements.isEmpty else { return self }
        let newStorage = storage.copy()
        newStorage.resolve(resolveSymlinks: false)
        return Self(storage: newStorage)
    }
}

extension RelativePath {
    public static let current = RelativePath(elements: []) // Current relative path is always "."
}

extension Collection where Element: Equatable {
    @usableFromInline
    func contains<Other: Collection>(_ other: Other) -> Bool where Other.Element == Element {
        guard let start = other.first else { return true }
        guard let searchStartIdx = firstIndex(of: start),
            case let otherCount = other.count, count >= other.count else { return false }
        var lowerBound = searchStartIdx
        while lowerBound < endIndex && distance(from: lowerBound, to: endIndex) >= otherCount {
            guard !self[lowerBound...].starts(with: other) else { return true }
            guard let nextIdx = self[index(after: lowerBound)...].firstIndex(of: start) else { return false }
            lowerBound = nextIdx
        }
        return false
    }
}

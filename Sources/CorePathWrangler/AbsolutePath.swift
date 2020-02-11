#if os(Linux)
import Glibc
#else
import Darwin.C
#endif
import CPathWrangler

public struct AbsolutePath: _PathProtocol {
    @usableFromInline
    static let isAbsolute = true

    @usableFromInline
    private(set) var storage: PathStorage

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
        storage.elements.starts(with: other.storage.elements)
    }

    @inlinable
    public mutating func resolve(resolveSymlinks: Bool = false) {
        guard !storage.elements.isEmpty else { return }
        copyStorageIfNeeded()
        storage.resolve(resolveSymlinks: resolveSymlinks)
    }

    @inlinable
    public func resolved(resolveSymlinks: Bool = false) -> Self {
        guard !storage.elements.isEmpty else { return self }
        let newStorage = storage.copy()
        newStorage.resolve(resolveSymlinks: resolveSymlinks)
        return Self(storage: newStorage)
    }
}

extension AbsolutePath {
    public static let root = Self(elements: [])

    public static var current: Self {
        Self(pathString: String(cString: getcwd(nil, 0)))
    }

    public static let tmpDir = Self(pathString: String(cString: cpw_tmp_dir_path())).resolved(resolveSymlinks: true)
}

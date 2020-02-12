#if os(Linux)
import Glibc
#else
import Darwin.C
#endif
import CPathWrangler

/// Represents an absolute path.
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

    /// Resolves (simplifies) the receiver, optionally including symlinks.
    /// By default this tries to resolve e.g. current directory (.) or parent directory (..) references.
    /// If `resolveSymlinks` is set to `true`, it also attempts to resolve symlinks. This requires the path to exist.
    /// - Parameter resolveSymlinks: Whether or not symlinks should be tried to resolve. This will only work if the path exists on disk.
    @inlinable
    public mutating func resolve(resolveSymlinks: Bool = false) {
        guard !storage.elements.isEmpty else { return }
        copyStorageIfNeeded()
        storage.resolve(resolveSymlinks: resolveSymlinks)
    }

    /// Returns a new path that has been resolved (simplified), optionally including symlinks.
    /// By default this tries to resolve e.g. current directory (.) or parent directory (..) references.
    /// If `resolveSymlinks` is set to `true`, it also attempts to resolve symlinks. This requires the path to exist.
    /// - Parameter resolveSymlinks: Whether or not symlinks should be tried to resolve. This will only work if the path exists on disk.
    @inlinable
    public func resolved(resolveSymlinks: Bool = false) -> Self {
        guard !storage.elements.isEmpty else { return self }
        let newStorage = storage.copy()
        newStorage.resolve(resolveSymlinks: resolveSymlinks)
        return Self(storage: newStorage)
    }
}

extension AbsolutePath {
    /// The absolute root path (/).
    public static let root = Self(elements: [])

    /// The current absolute path (cwd).
    public static var current: Self {
        Self(pathString: String(cString: getcwd(nil, 0)))
    }

    /// The absolute path to the system's temporary directory. Note that this does not create a new subdirectory (like `mktemp` would).
    public static let tmpDir = Self(pathString: String(cString: cpw_tmp_dir_path())).resolved(resolveSymlinks: true)
}

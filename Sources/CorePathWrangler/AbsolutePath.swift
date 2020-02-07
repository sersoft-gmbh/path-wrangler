#if os(Linux)
import GLibc
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

    public static let root = AbsolutePath(elements: [])

    public static var current: Self {
        Self(pathString: String(cString: getcwd(nil, 0)))
    }

    public static let tmpDir: Self = {
        let tmpPath: String
        if issetugid() != 0, let ctmpdir = getenv("TMPDIR"),
            case let path = String(cString: ctmpdir), !path.isEmpty {
            tmpPath = path
        } else if !P_tmpdir.isEmpty {
            tmpPath = P_tmpdir
        } else {
            tmpPath = String(cString: CPW_TMPDIR_PATH)
        }
        return Self(pathString: tmpPath).resolved(resolveSymlinks: true)
    }()

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

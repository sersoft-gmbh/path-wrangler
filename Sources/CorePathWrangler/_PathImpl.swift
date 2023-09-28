#if os(Linux)
import Glibc
#else
import Darwin.C
#endif
import Algorithms
import CPathWrangler

@usableFromInline
struct _PathImpl: Sendable {
    @usableFromInline
    let isAbsolute: Bool

    @usableFromInline
    var elements: Array<PathElement>

    @inlinable
    var lastPathElement: PathElement {
        get {
            assert(!elements.isEmpty)
            return elements[elements.lastSafeSubscriptIndex]
        }
        set {
            assert(!elements.isEmpty)
            elements[elements.lastSafeSubscriptIndex] = newValue
        }
    }

    @usableFromInline
    var pathString: String {
        elements.pathString(absolute: isAbsolute)
    }

    @usableFromInline
    init(isAbsolute: Bool, elements: Array<PathElement> = .init()) {
        self.isAbsolute = isAbsolute
        self.elements = elements
    }

    @inlinable
    init(isAbsolute: Bool, pathString: String) {
        self.init(isAbsolute: isAbsolute,
                  elements: PathElement.elements(from: pathString))
    }

    @inlinable
    mutating func append(pathComponents: some Sequence<any PathComponentConvertible>) {
        elements.append(contentsOf: pathComponents.flatMap(\.pathElements))
    }

    private func resolvedSymlink(at path: String) -> String? {
        var statresult = stat()
        guard lstat(path, &statresult) == 0 else {
            print("lstat failed (\(errno)) \(String(cString: strerror(errno)))!")
            return nil
        }
        guard cpw_mode_is_link(statresult.st_mode) else { return nil }
        let allocationSize: Int = numericCast(statresult.st_size) + 1
        let dstPtr = UnsafeMutablePointer<Int8>.allocate(capacity: allocationSize)
        defer { dstPtr.deallocate() }
        let readlinkSize = readlink(path, dstPtr, allocationSize)
        guard readlinkSize >= 0 else {
            print("readlink failed (\(errno)) \(String(cString: strerror(errno)))!")
            return nil
        }
        if readlinkSize != statresult.st_size {
            print("link size changed between lstat and readlink!")
            return nil
        }
        dstPtr[allocationSize - 1] = 0
        return String(cString: dstPtr)
    }

    private enum SymlinkStatus: Sendable {
        case noLink
        case isLink(Array<PathElement>)
    }

    private func resolve<Elements>(elements: inout Elements,
                                   resolveSymlinks: Bool,
                                   symlinkCache: inout Dictionary<String, SymlinkStatus>)
    where Elements: RandomAccessCollection,
          Elements: MutableCollection,
          Elements: RangeReplaceableCollection,
          Elements.Element == PathElement
    {
        assert(!elements.isEmpty)
        assert(!resolveSymlinks || isAbsolute, "Symlinks cannot be resolved for relative paths")
        // This sort of performs a half stable partition moving all elements to the back that should be removed.
        // We don't care about the ordering of the elements in the back. We just need the elements the front to stay in the same order.
        var minSafeIndex = elements.startIndex
        var currentIdx = elements.startIndex
        var splitIndex = elements.endIndex
        while currentIdx < splitIndex {
            @inline(__always)
            func rotate(from lowerBound: Elements.Index) {
                elements[lowerBound...].rotate(toStartAt: elements.index(after: currentIdx))
                elements.formIndex(&splitIndex, offsetBy: elements.distance(from: currentIdx, to: lowerBound) - 1)
            }
            @inline(__always)
            func resolveSymlinksIfNeeded() -> Bool {
                guard resolveSymlinks && minSafeIndex == elements.startIndex else { return true }
                let pathStringToResolve = elements[...currentIdx].pathString(absolute: isAbsolute)
                let cached = symlinkCache[pathStringToResolve]
                let linkStatus = cached ?? resolvedSymlink(at: pathStringToResolve).map { .isLink($0.pathElements) } ?? .noLink
                if case .isLink(var resolved) = linkStatus {
                    resolve(elements: &resolved, resolveSymlinks: resolveSymlinks, symlinkCache: &symlinkCache)
                    symlinkCache[pathStringToResolve] = .isLink(resolved)
                    let offsetDiff = resolved.count - elements[...currentIdx].count
                    elements.formIndex(&splitIndex, offsetBy: offsetDiff)
                    elements.replaceSubrange(...currentIdx, with: resolved)
                    if cached == nil {
                        currentIdx = elements.startIndex
                        return false // we need to perform the symlink check again in case we have a linked link.
                    } else {
                        elements.formIndex(&currentIdx, offsetBy: offsetDiff)
                    }
                } else {
                    symlinkCache[pathStringToResolve] = linkStatus
                }
                return true
            }
            switch elements[currentIdx].simplificationAction {
            case .none:
                guard resolveSymlinksIfNeeded() else { continue }
                elements.formIndex(after: &currentIdx)
            case .remove: rotate(from: currentIdx)
            case .removeParent:
                if currentIdx > minSafeIndex {
                    rotate(from: elements.index(before: currentIdx))
                    elements.formIndex(before: &currentIdx) // we moved two elements to the end, thus we need to go backwards one step with our current idx.
                } else if isAbsolute { // absolute paths cannot move above root. `/../ == /`
                    rotate(from: currentIdx)
                } else {
                    elements.formIndex(after: &currentIdx)
                    minSafeIndex = currentIdx
                }
            }
        }
        elements[splitIndex...].removeAll()
    }

    @usableFromInline
    mutating func resolve(resolveSymlinks: Bool) {
        var symlinkMap = Dictionary<String, SymlinkStatus>()
        resolve(elements: &elements, resolveSymlinks: resolveSymlinks, symlinkCache: &symlinkMap)
    }
}

extension BidirectionalCollection {
    @inlinable
    var lastSafeSubscriptIndex: Index { index(before: endIndex) }
}

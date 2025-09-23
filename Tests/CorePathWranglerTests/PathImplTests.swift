import Foundation
import Testing
@testable import CorePathWrangler

@Suite
struct PathImplTests {
    @Test
    func initialization() {
        #expect(!_PathImpl(isAbsolute: false).isAbsolute)
        #expect(_PathImpl(isAbsolute: true).isAbsolute)
        #expect(_PathImpl(isAbsolute: false).elements.isEmpty)
        let storage = _PathImpl(isAbsolute: false, elements: [PathElement(name: "test")])
        #expect(!storage.isAbsolute)
        #expect(storage.elements == [PathElement(name: "test")])
        let storage2 = _PathImpl(isAbsolute: true, pathString: "/a/b/c")
        #expect(storage2.isAbsolute)
        #expect(storage2.elements == PathElement.elements(from: "/a/b/c"))
    }

    @Test
    func elementsUpdateResetsPathStringStorage() {
        var storage = _PathImpl(isAbsolute: false)
        storage.elements = [PathElement(name: "test")]
        let oldString = storage.pathString
        storage.elements = [PathElement(name: "test2")]
        let newString = storage.pathString
        #expect(oldString != newString)
    }

    @Test
    func lastPathElement() {
        var storage = _PathImpl(isAbsolute: false)
        storage.elements = [PathElement(name: "test"), PathElement(name: "test2")]
        #expect(storage.lastPathElement.name == "test2")
        storage.lastPathElement = PathElement(name: "test3")
        #expect(storage.lastPathElement.name == "test3")
        #expect(storage.elements == [PathElement(name: "test"), PathElement(name: "test3")])
        storage.lastPathElement = PathElement(name: "test4")
        #expect(storage.elements == [PathElement(name: "test"), PathElement(name: "test4")])
    }

    @Test
    func appending() {
        var storage = _PathImpl(isAbsolute: false)
        storage.append(pathComponents: CollectionOfOne(PathElement(name: "test")))
        storage.append(pathComponents: CollectionOfOne("test2"))
        #expect(storage.elements == [PathElement(name: "test"), PathElement(name: "test2")])
    }

    @Test
    func lastSafeSubsciptIndex() {
        let arr = ["1"]
        #expect(arr.lastSafeSubscriptIndex == arr.index(before: arr.endIndex))
    }

    @Test
    func resolvingWithoutSymlinks() {
        var relStorage = _PathImpl(isAbsolute: false)
        relStorage.elements = [PathElement(name: "test"), PathElement(name: "test2")]
        relStorage.resolve(resolveSymlinks: false)
        #expect(relStorage.elements == [PathElement(name: "test"), PathElement(name: "test2")])
        relStorage.elements = [PathElement(name: "test"), PathElement(name: "..")]
        relStorage.resolve(resolveSymlinks: false)
        #expect(relStorage.elements.isEmpty)
        relStorage.elements = [PathElement(name: "."), PathElement(name: "..")]
        relStorage.resolve(resolveSymlinks: false)
        #expect(relStorage.elements == [PathElement(name: "..")])
        relStorage.elements = [PathElement(name: "."),
                               PathElement(name: "test"),
                               PathElement(name: "."),
                               PathElement(name: "test2"),
                               PathElement(name: "..")]
        relStorage.resolve(resolveSymlinks: false)
        #expect(relStorage.elements == [PathElement(name: "test")])

        var absStorage = _PathImpl(isAbsolute: true)
        absStorage.elements = [PathElement(name: "test"), PathElement(name: "test2")]
        absStorage.resolve(resolveSymlinks: false)
        #expect(absStorage.elements == [PathElement(name: "test"), PathElement(name: "test2")])
        absStorage.elements = [PathElement(name: "test"), PathElement(name: "..")]
        absStorage.resolve(resolveSymlinks: false)
        #expect(absStorage.elements.isEmpty)
        absStorage.elements = [PathElement(name: "."), PathElement(name: "..")]
        absStorage.resolve(resolveSymlinks: false)
        #expect(absStorage.elements.isEmpty)
        absStorage.elements = [PathElement(name: "."),
                               PathElement(name: "test"),
                               PathElement(name: "."),
                               PathElement(name: "test2"),
                               PathElement(name: "..")]
        absStorage.resolve(resolveSymlinks: false)
        #expect(absStorage.elements == [PathElement(name: "test")])
    }

    @Test
    func resolvingLongPathsWithoutSymlinks() {
        var absStorage1 = _PathImpl(isAbsolute: true, pathString: "/A/B/C/D/./E/.././../F/../G/H/I")
        var absStorage2 = _PathImpl(isAbsolute: true, pathString: "/A/../../B/C/D/./E/.././../F/../G/H/I")
        var absStorage3 = _PathImpl(isAbsolute: true, pathString: "/./A/./../././../B/././C/D/./E/.././../F/../G/./H/I")
        var absStorage4 = _PathImpl(isAbsolute: true, pathString: "/.././A/./../././../B/././C/D/./E/.././../F/../G/./H/I/.")
        var absStorage5 = _PathImpl(isAbsolute: true, pathString: "/.././.././A/../..")
        absStorage1.resolve(resolveSymlinks: false)
        absStorage2.resolve(resolveSymlinks: false)
        absStorage3.resolve(resolveSymlinks: false)
        absStorage4.resolve(resolveSymlinks: false)
        absStorage5.resolve(resolveSymlinks: false)
        #expect(absStorage1.pathString == "/A/B/C/G/H/I")
        #expect(absStorage2.pathString == "/B/C/G/H/I")
        #expect(absStorage3.pathString == "/B/C/G/H/I")
        #expect(absStorage4.pathString == "/B/C/G/H/I")
        #expect(absStorage5.pathString == "/")

        var relStorage1 = _PathImpl(isAbsolute: false, pathString: "A/B/C/D/./E/.././../F/../G/H/I")
        var relStorage2 = _PathImpl(isAbsolute: false, pathString: "A/../../B/C/D/./E/.././../F/../G/H/I")
        var relStorage3 = _PathImpl(isAbsolute: false, pathString: "./A/./../././../B/././C/D/./E/.././../F/../G/./H/I")
        var relStorage4 = _PathImpl(isAbsolute: false, pathString: ".././A/./../././../B/././C/D/./E/.././../F/../G/./H/I/.")
        var relStorage5 = _PathImpl(isAbsolute: false, pathString: ".././.././A/../..")
        relStorage1.resolve(resolveSymlinks: false)
        relStorage2.resolve(resolveSymlinks: false)
        relStorage3.resolve(resolveSymlinks: false)
        relStorage4.resolve(resolveSymlinks: false)
        relStorage5.resolve(resolveSymlinks: false)
        #expect(relStorage1.pathString == "A/B/C/G/H/I")
        #expect(relStorage2.pathString == "../B/C/G/H/I")
        #expect(relStorage3.pathString == "../B/C/G/H/I")
        #expect(relStorage4.pathString == "../../B/C/G/H/I")
        #expect(relStorage5.pathString == "../../..")
    }

    @Test
    func resolvingWithSymlinks() {
        var storage = _PathImpl(isAbsolute: true)
        storage.elements = [PathElement(name: "test"), PathElement(name: "test2")]
        storage.resolve(resolveSymlinks: true)
        #expect(storage.elements == [PathElement(name: "test"), PathElement(name: "test2")])
        storage.elements = [PathElement(name: "test"), PathElement(name: "..")]
        storage.resolve(resolveSymlinks: true)
        #expect(storage.elements.isEmpty)
        storage.elements = [PathElement(name: "."), PathElement(name: "..")]
        storage.resolve(resolveSymlinks: true)
        #expect(storage.elements.isEmpty)
        storage.elements = [PathElement(name: "."),
                            PathElement(name: "test"),
                            PathElement(name: "."),
                            PathElement(name: "test2"),
                            PathElement(name: "..")]
        storage.resolve(resolveSymlinks: true)
        #expect(storage.elements == [PathElement(name: "test")])

        let tempDir = AbsolutePath.tmpDir
        let subDir1 = tempDir / "folder"
        let linkDir1 = subDir1 / "link"
        let linkDest1 = subDir1 / "folder2"
#if compiler(>=6.2)
        unsafe mkdir(subDir1.pathString, 0o700)
        unsafe mkdir(linkDest1.pathString, 0o700)
        unsafe symlink(linkDest1.pathString, linkDir1.pathString)
#else
        mkdir(subDir1.pathString, 0o700)
        mkdir(linkDest1.pathString, 0o700)
        symlink(linkDest1.pathString, linkDir1.pathString)
#endif
        let subDir2 = linkDir1 / "subfolder"
        let subLink2 = subDir2 / "link2"
        let subDest2 = subDir2 / "folder3"
#if compiler(>=6.2)
        unsafe mkdir(subDir2.pathString, 0o700)
        unsafe mkdir(subDest2.pathString, 0o700)
        unsafe symlink(subDest2.pathString, subLink2.pathString)
#else
        mkdir(subDir2.pathString, 0o700)
        mkdir(subDest2.pathString, 0o700)
        symlink(subDest2.pathString, subLink2.pathString)
#endif
        let finalPath = subLink2 / "target"
        storage.elements = finalPath._impl.elements
        storage.resolve(resolveSymlinks: true)
        defer {
#if compiler(>=6.2)
            unsafe remove(finalPath.pathString)
            unsafe remove(subDest2.pathString)
            unsafe remove(subLink2.pathString)
            unsafe remove(subDir2.pathString)
            unsafe remove(linkDest1.pathString)
            unsafe remove(linkDir1.pathString)
            unsafe remove(subDir1.pathString)
#else
            remove(finalPath.pathString)
            remove(subDest2.pathString)
            remove(subLink2.pathString)
            remove(subDir2.pathString)
            remove(linkDest1.pathString)
            remove(linkDir1.pathString)
            remove(subDir1.pathString)
#endif
        }
        #expect(storage.elements
                ==
                tempDir._impl.elements
                + ["folder", "folder2", "subfolder", "folder3", "target"].map { PathElement(name: $0) })
        #expect(storage.elements.map { $0.name }
                ==
                tempDir._impl.elements.map { $0.name }
                + ["folder", "folder2", "subfolder", "folder3", "target"])
    }
}

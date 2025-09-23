import Testing
@testable import CorePathWrangler

@Suite
struct PathElementTests {
    @Test
    func initialization() {
        let pathElement = PathElement(name: "test", extensions: ["t1"])
        #expect(pathElement.name == "test")
        #expect(pathElement.extensions == ["t1"])
    }

    @Test
    func pathComponentConvertibleConformance() {
        let pathElement = PathElement(name: "test", extensions: ["t1", "t2"])
        #expect(pathElement.pathComponent == "test.t1.t2")
    }

    @Test
    func simplifactionAction() {
        #expect(PathElement(name: "test").simplificationAction == .none)
        #expect(PathElement(name: ".").simplificationAction == .remove)
        #expect(PathElement(name: "..").simplificationAction == .removeParent)
    }

    @Test
    func appendingExtensions() {
        var pathElement = PathElement(name: "test")
        #expect(pathElement.extensions.isEmpty)
        pathElement.append(pathExtension: "t1")
        #expect(pathElement.extensions == ["t1"])
    }

    @Test
    func removingPathExtensions() {
        var pathElement = PathElement(name: "test", extensions: ["t1"])
        pathElement.removeLastPathExtension()
        #expect(pathElement.extensions.isEmpty)
    }

    @Test
    func convenienceExtensionOnPathComponentConvertible() {
        let convertible = "A/B.test"
        #expect(convertible.pathElements == [PathElement(name: "A"), PathElement(name: "B", extensions: ["test"])])
    }

    @Test
    func pathStringComputationAndParsing() {
        let elements = [
            PathElement(name: "test"),
            PathElement(name: "these", extensions: ["t1"]),
            PathElement(name: "elements", extensions: ["t2", "t3"]),
            PathElement(name: ".."),
            PathElement(name: "."),
            PathElement(name: "end"),
        ]
        let relPathString = "test/these.t1/elements.t2.t3/.././end"
        let absPathString = "/test/these.t1/elements.t2.t3/.././end"
        #expect(PathElement.elements(from: relPathString) == elements)
        #expect(PathElement.elements(from: absPathString) == elements)
        #expect(elements.pathString(absolute: false) == relPathString)
        #expect(elements.pathString(absolute: true) == absPathString)
        #expect(EmptyCollection<PathElement>().pathString(absolute: false) == ".")
        #expect(EmptyCollection<PathElement>().pathString(absolute: true) == "/")
        #expect(PathElement.elements(from: ".") == [PathElement(name: ".")])
        #expect(PathElement.elements(from: "/").isEmpty)
    }
}

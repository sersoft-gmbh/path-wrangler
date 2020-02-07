import XCTest
import PathWrangler

final class PathWranglerTests: XCTestCase {
    func testExample() {
        var path = AbsolutePath(pathString: "/A/B/C")
        path.append(RelativePath(pathString: "D"))
        XCTAssertEqual(path.pathString, "/A/B/C/D")
    }
}

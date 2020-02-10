import XCTest
import PathWrangler

final class PathComponentConvertibleConformancesTests: XCTestCase {
    func testUUIDPathComponentConvertibleConformance() {
        let uuid = UUID()
        XCTAssertEqual(uuid.pathComponent, uuid.uuidString)
    }

    func testDecimalPathComponentConvertibleConformance() {
        let decimal: Decimal = 12.34
        XCTAssertEqual(decimal.pathComponent, NSDecimalNumber(decimal: decimal).stringValue)
    }
}

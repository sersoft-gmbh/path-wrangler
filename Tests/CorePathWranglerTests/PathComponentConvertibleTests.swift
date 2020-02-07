import XCTest
import CorePathWrangler

final class PathComponentConvertibleTests: XCTestCase {
    func testStringConformance() {
        let string: String = "ABC"
        XCTAssertEqual(string.pathComponent, "ABC")
    }

    func testStaticStringConformance() {
        let staticString: StaticString = "ABC"
        let shortStaticString = StaticString(_builtinUnicodeScalarLiteral: UInt32(0x5a)._value)
        XCTAssertEqual(staticString.pathComponent, "ABC")
        XCTAssertEqual(shortStaticString.pathComponent, "\u{5a}")
    }

    func testBinaryIntegerConformance() {
        let int8: Int8 = -42
        let int16: Int16 = -42
        let int32: Int32 = -42
        let int64: Int64 = -42
        let int: Int = -42
        let uInt8: UInt8 = 42
        let uInt16: UInt16 = 42
        let uInt32: UInt32 = 42
        let uInt64: UInt64 = 42
        let uInt: UInt = 42
        XCTAssertEqual(int8.pathComponent, "-42")
        XCTAssertEqual(int16.pathComponent, "-42")
        XCTAssertEqual(int32.pathComponent, "-42")
        XCTAssertEqual(int64.pathComponent, "-42")
        XCTAssertEqual(int.pathComponent, "-42")
        XCTAssertEqual(uInt8.pathComponent, "42")
        XCTAssertEqual(uInt16.pathComponent, "42")
        XCTAssertEqual(uInt32.pathComponent, "42")
        XCTAssertEqual(uInt64.pathComponent, "42")
        XCTAssertEqual(uInt.pathComponent, "42")
    }

    func testFloatingPointConformance() {
        let flt: Float = 1.2
        let dbl: Double = 3.4
        XCTAssertEqual(flt.pathComponent, "1.2")
        XCTAssertEqual(dbl.pathComponent, "3.4")
    }

    func testRawRepresentableConformance() {
        enum TestEnum: Int, RawRepresentable, PathComponentConvertible {
            case one = 1, two = 2
        }
        XCTAssertEqual(TestEnum.one.pathComponent, TestEnum.one.rawValue.pathComponent)
    }
}

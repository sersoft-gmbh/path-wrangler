import XCTest
@testable import StdLibAlgorithms

fileprivate func expectEqual<T : Equatable>(
  _ expected: T, _ x: T, file: StaticString = #file, line: UInt = #line
) {
    XCTAssertEqual(expected, x, file: file, line: line)
}

fileprivate func expectGE<T: Comparable>(
  _ a: T, _ b: T, _ message: @autoclosure ()->String = "",
  file: StaticString = #file, line: UInt = #line
) {
    XCTAssertGreaterThanOrEqual(a, b, message(), file: file, line: line)
}

fileprivate func expectLE<T: Comparable>(
  _ a: T, _ b: T, _ message: @autoclosure ()->String = "",
  file: StaticString = #file, line: UInt = #line
) {
  XCTAssertLessThanOrEqual(a, b, message(), file: file, line: line)
}

fileprivate func address<T>(_ p: UnsafePointer<T>) -> UInt { return UInt(bitPattern: p )}

final class AlgorithmsTests: XCTestCase {
    func testReverseSubrange() {
      for l in 0..<10 {
        let a = Array(0..<l)

        for p in a.startIndex...a.endIndex {
          let prefix = a[..<p]
          for q in p...l {
            let suffix = a[q...]

            var b = a
            b.reserveCapacity(b.count)  // guarantee unique storage
            let id = address(b)

            b[p..<q].reverse()
            expectEqual(
              b,
              Array([prefix, ArraySlice(a[p..<q].reversed()), suffix].joined()))
            expectEqual(address(b), id)
          }
        }
      }
    }

    func testRotate() {
      for l in 0..<11 {
        let a = Array(0..<l)

        for p in a.startIndex...a.endIndex {
          let prefix = a[..<p]
          for q in p...l {
            let suffix = a[q...]

            for m in p...q {
              var b = a
              b.reserveCapacity(b.count)  // guarantee unique storage
              let id = address(b)

              let r = b[p..<q].rotate(shiftingToStart: m)
              let rotated = Array([prefix, a[m..<q], a[p..<m], suffix].joined())
              expectEqual(b, rotated)
              expectEqual(r, a.index(p, offsetBy: a[m..<q].count))
              expectEqual(address(b), id)
            }
          }
          var b = a
          b.rotate(shiftingToStart: p)
          expectEqual(b, Array(a.rotated(shiftingToStart: p)))
        }
      }
    }

    func testRotateRandomAccess() {
      for l in 0..<11 {
        let a = Array(0..<l)

        for p in a.startIndex...a.endIndex {
          let prefix = a[..<p]
          for q in p...l {
            let suffix = a[q...]

            for m in p...q {
              var b = a
              b.reserveCapacity(b.count)  // guarantee unique storage
              let id = address(b)

              let r = b[p..<q].rotateRandomAccess(shiftingToStart: m)
              let rotated = Array([prefix, a[m..<q], a[p..<m], suffix].joined())
              expectEqual(b, rotated)
              expectEqual(r, a.index(p, offsetBy: a[m..<q].count))
              expectEqual(address(b), id)
            }
          }
          var b = a
          b.rotateRandomAccess(shiftingToStart: p)
          expectEqual(b, Array(a.rotated(shiftingToStart: p)))
        }
      }
    }

    func testConcatenate() {
      for x in 0...6 {
        for y in 0...x {
          let r1 = 0..<y
          let r2 = y..<x
          expectEqual(Array(0..<x), Array(concatenate(r1, r2)))
        }
      }

      let c1 = concatenate([1, 2, 3, 4, 5], 6...10)
      let c2 = concatenate(1...5, [6, 7, 8, 9, 10])
      expectEqual(Array(1...10), Array(c1))
      expectEqual(Array(1...10), Array(c2))

      let h = "Hello, "
      let w = "world!"
      let hw = concatenate(h, w)
      expectEqual("Hello, world!", String(hw))

      let run = (1...).prefix(10).followed(by: 20...)
      expectEqual(Array(run.prefix(20)), Array(1...10) + (20..<30))
    }

    func testStablePartition() {
      // FIXME: add test for stability
      for l in 0..<13 {
        let a = Array(0..<l)

        for p in a.startIndex...a.endIndex {
          let prefix = a[..<p]
          for q in p...l {
            let suffix = a[q...]

            let subrange = a[p..<q]

            for modulus in 1...5 {
              let f = { $0 % modulus != 0 }
              let notf = { !f($0) }

              var b = a
              b.reserveCapacity(b.count)  // guarantee unique storage
              let id = address(b)

              var r = b[p..<q].stablePartition(isSuffixElement: f)
              expectEqual(b[..<p], prefix)
              expectEqual(b.suffix(from:q), suffix)
              expectEqual(b[p..<r], ArraySlice(subrange.filter(notf)))
              expectEqual(b[r..<q], ArraySlice(subrange.filter(f)))
              expectEqual(address(b), id)

              b = a
              r = b[p..<q].stablePartition(isSuffixElement: notf)
              expectEqual(b[..<p], prefix)
              expectEqual(b.suffix(from:q), suffix)
              expectEqual(b[p..<r], ArraySlice(subrange.filter(f)))
              expectEqual(b[r..<q], ArraySlice(subrange.filter(notf)))
            }
          }

          for modulus in 1...5 {
            let f = { $0 % modulus != 0 }
            let notf = { !f($0) }
            var b = a
            var r = b.stablePartition(isSuffixElement: f)
            expectEqual(b[..<r], ArraySlice(a.filter(notf)))
            expectEqual(b[r...], ArraySlice(a.filter(f)))

            b = a
            r = b.stablePartition(isSuffixElement: notf)
            expectEqual(b[..<r], ArraySlice(a.filter(f)))
            expectEqual(b[r...], ArraySlice(a.filter(notf)))
          }
        }
      }
    }

    func testPartitionPoint() {
      for i in 0..<7 {
        for j in i..<11 {
          for k in i...j {
            let p = (i..<j).partitionPoint { $0 >= k }
            expectGE(p, i, "\(p) >= \(i)")
            expectLE(p, j, "\(p) <= \(j)")
            expectEqual(p, k)
          }
        }
      }
    }
}

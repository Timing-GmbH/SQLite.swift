import XCTest
import SQLite

class FoundationTests : XCTestCase {
    func testDataToBlob() {
        let data = Data([1, 2, 3])
        let blob = data.datatypeValue
        XCTAssertEqual([1, 2, 3], blob.bytes)
    }

    func testBlobToData() {
        let blob = Blob(bytes: [1, 2, 3])
        let data = Data.fromDatatypeValue(blob)
        XCTAssertEqual(Data([1, 2, 3]), data)
    }

    func testStringToURL() throws {
        XCTAssertThrowsError(try URL.fromDatatypeValue(""))
        XCTAssertEqual(URL(string: "/")!, try URL.fromDatatypeValue("/"))
    }
}

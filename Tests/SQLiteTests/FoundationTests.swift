import XCTest
import SQLite

class FoundationTests : SQLiteTestCase {
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

    func testURLColumn() throws {
        try! db.execute("""
            CREATE TABLE websites (
                id INTEGER PRIMARY KEY,
                url TEXT
            )
            """)
        try db.run("INSERT INTO `websites` (url) VALUES (\"\")")
        try db.run("INSERT INTO `websites` (url) VALUES (\"https://example.com\")")

        // Primitive values show what's in the DB
        let websiteURLStrings = try db
            .prepare("SELECT `url` FROM `websites`")
            .map { (try! $0.unwrapOrThrow()[0]) as! String  }
        XCTAssertEqual(websiteURLStrings, ["", "https://example.com"])

        // Types SQLite.swift wrappers show failing URL unwrapping
        let websites = Table("websites")
        let url = Expression<URL?>("url")
        let allWebsites = try Array(try db.prepare(websites)).map { try $0.unwrapOrThrow() }
        XCTAssertThrowsError(try allWebsites[0].get(url)) {
            XCTAssert($0 is URL.URLRiskyValueError)
        }
        XCTAssertEqual(URL(string: "https://example.com")!,
                       try allWebsites[1].get(url))
    }
}

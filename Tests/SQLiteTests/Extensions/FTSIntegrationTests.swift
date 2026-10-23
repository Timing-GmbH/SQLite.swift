import XCTest
#if SQLITE_SWIFT_STANDALONE
import sqlite3
#elseif SQLITE_SWIFT_SQLCIPHER
import SQLCipher
#else
import CSQLite
#endif
@testable import SQLiteSwift

class FTSIntegrationTests: SQLiteTestCase {
    let email = SQLiteSwift.Expression<String>("email")
    let index = VirtualTable("index")

    private func createIndex() throws {
        try createOrSkip { db in
            try db.run(index.create(.FTS5(
                FTS5Config()
                    .column(email)
                    .tokenizer(.Unicode61()))
            ))
        }

        for user in try db.prepare(users) {
            try db.run(index.insert(email <- try user.unwrapOrThrow()[email]))
        }
    }

    private func createTrigramIndex() throws {
        try createOrSkip { db in
            try db.run(index.create(.FTS5(
                FTS5Config()
                  .column(email)
                  .tokenizer(.Trigram(caseSensitive: false)))
            ))
        }

        for user in try db.prepare(users) {
            try db.run(index.insert(email <- try user.unwrapOrThrow()[email]))
        }
    }

    override func setUpWithError() throws {
        try super.setUpWithError()
        try createUsersTable()
        try insertUsers("John", "Paul", "George", "Ringo")
    }

    func testMatch() throws {
        try createIndex()
        let matches = Array(try db.prepare(index.match("Paul")))
        XCTAssertEqual(try matches.map { try $0.unwrapOrThrow()[email] }, ["Paul@example.com"])
    }

    func testMatchPartial() throws {
        try insertUsers("Paula")
        try createIndex()
        let matches = Array(try db.prepare(index.match("Pa*")))
        XCTAssertEqual(try matches.map { try $0.unwrapOrThrow()[email] }, ["Paul@example.com", "Paula@example.com"])
    }

    func testTrigramIndex() throws {
        try createTrigramIndex()
        let matches = Array(try db.prepare(index.match("Paul")))
        XCTAssertEqual(1, matches.count)
    }

    func testWeightedBM25ChangesResultOrder() throws {
        let articles = VirtualTable("articles")
        let title = SQLiteSwift.Expression<String>("title")
        let body = SQLiteSwift.Expression<String>("body")
        try createOrSkip { db in
            try db.run(articles.create(.FTS5(FTS5Config().columns([title, body]))))
        }

        try db.run(articles.insert(title <- "swift swift", body <- "other"))
        try db.run(articles.insert(title <- "other", body <- "swift swift"))

        let titleFirst = try db.prepare(articles.match("swift").order(articles.bm25(10.0, 1.0)))
        XCTAssertEqual(try titleFirst.map { try $0.unwrapOrThrow()[title] }, ["swift swift", "other"])

        let bodyFirst = try db.prepare(articles.match("swift").order(articles.bm25(1.0, 10.0)))
        XCTAssertEqual(try bodyFirst.map { try $0.unwrapOrThrow()[title] }, ["other", "swift swift"])
    }

    private func createOrSkip(_ createIndex: (Connection) throws -> Void) throws {
        do {
            try createIndex(db)
        } catch let error as Result {
            try XCTSkipIf(error.description.starts(with: "no such module:") ||
                          error.description.starts(with: "parse error")
            )
            throw error
        }
    }
}

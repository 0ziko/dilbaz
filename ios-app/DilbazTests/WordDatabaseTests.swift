import XCTest
@testable import Dilbaz

final class WordDatabaseTests: XCTestCase {
    private func loadTestDatabase() throws -> WordDatabase {
        let bundle = Bundle(for: type(of: self))
        let url = try XCTUnwrap(bundle.url(forResource: "word_db", withExtension: "json"))
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(WordDatabase.self, from: data)
    }

    func testCountsMatchExpected() throws {
        let db = try loadTestDatabase()
        XCTAssertEqual(db.tr.words.count, 5919)
        XCTAssertEqual(db.tr.atasozu.count, 2251)
        XCTAssertEqual(db.tr.deyim.count, 10751)
        XCTAssertEqual(db.en.words.count, 47187)
    }

    func testDailyPuzzleIsDeterministic() throws {
        let db = try loadTestDatabase()
        let date = Date(timeIntervalSince1970: 1_780_000_000)
        let first = db.dailyPuzzle(language: .tr, date: date)
        let second = db.dailyPuzzle(language: .tr, date: date)
        XCTAssertEqual(first.id, second.id, "Aynı tarih için farklı bulmaca seçilmemeli")
    }

    func testCategoryEntriesReturnAnimals() throws {
        let db = try loadTestDatabase()
        let animals = db.categoryEntries("hayvanlar")
        XCTAssertFalse(animals.isEmpty)
    }
}

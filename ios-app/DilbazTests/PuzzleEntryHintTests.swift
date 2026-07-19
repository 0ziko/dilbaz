import XCTest
@testable import Dilbaz

final class PuzzleEntryHintTests: XCTestCase {
    func testHintMentionsRepeatedLetterWhenPresent() {
        let puzzle = PuzzleEntry(
            id: "t1", text: "kelime", letters: "KELİME", letterCount: 6,
            type: "word", difficulty: 1.2, frequencyRank: nil, frequencyCount: nil,
            definition: nil, origin: nil
        )
        XCTAssertTrue(puzzle.hintText.contains("birden fazla"))
    }

    func testHintMentionsAllDifferentWhenNoRepeats() {
        let puzzle = PuzzleEntry(
            id: "t2", text: "kalem", letters: "KALEM", letterCount: 5,
            type: "word", difficulty: 1.0, frequencyRank: nil, frequencyCount: nil,
            definition: nil, origin: nil
        )
        XCTAssertTrue(puzzle.hintText.contains("farklı"))
    }
}

import XCTest
@testable import Dilbaz

final class DifficultyTierTests: XCTestCase {
    func testBoundaries() {
        XCTAssertEqual(DifficultyTier.forLetterCount(4), .kolay)
        XCTAssertEqual(DifficultyTier.forLetterCount(7), .kolay)
        XCTAssertEqual(DifficultyTier.forLetterCount(8), .normal)
        XCTAssertEqual(DifficultyTier.forLetterCount(12), .normal)
        XCTAssertEqual(DifficultyTier.forLetterCount(13), .zor)
        XCTAssertEqual(DifficultyTier.forLetterCount(20), .zor)
        XCTAssertEqual(DifficultyTier.forLetterCount(21), .cokZor)
        XCTAssertEqual(DifficultyTier.forLetterCount(100), .cokZor)
    }
}

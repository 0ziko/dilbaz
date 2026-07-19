import XCTest
@testable import Dilbaz

final class DilHubModeTests: XCTestCase {
    func testAllCasesCount() {
        XCTAssertEqual(DilHubMode.allCases.count, 4)
    }

    func testDailyClassicIsFirstAndUsesBlueGradient() {
        XCTAssertEqual(DilHubMode.allCases.first, .dailyClassic)
    }

    func testEachModeHasNonEmptySubtitleAndIcon() {
        for mode in DilHubMode.allCases {
            XCTAssertFalse(mode.subtitle.isEmpty)
            XCTAssertFalse(mode.iconName.isEmpty)
        }
    }
}

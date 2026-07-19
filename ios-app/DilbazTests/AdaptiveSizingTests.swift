import XCTest
@testable import Dilbaz

final class AdaptiveSizingTests: XCTestCase {
    func testItemSizeClampsToMax() {
        let size = AdaptiveSizing.itemSize(availableWidth: 1000, itemCount: 4, spacing: 6, minSize: 20, maxSize: 48)
        XCTAssertEqual(size, 48)
    }

    func testItemSizeClampsToMin() {
        let size = AdaptiveSizing.itemSize(availableWidth: 100, itemCount: 20, spacing: 6, minSize: 20, maxSize: 48)
        XCTAssertEqual(size, 20)
    }

    func testItemSizeFitsWithinRange() {
        // 5 kutu, 4 aralık (spacing 6): (300 - 24) / 5 = 55.2 -> maxSize 48'e clamp.
        let size = AdaptiveSizing.itemSize(availableWidth: 300, itemCount: 5, spacing: 6, minSize: 20, maxSize: 48)
        XCTAssertEqual(size, 48)
    }

    func testRequiresHorizontalScrollWhenBelowMin() {
        let needsScroll = AdaptiveSizing.requiresHorizontalScroll(availableWidth: 200, itemCount: 20, spacing: 6, minSize: 20)
        XCTAssertTrue(needsScroll)
    }

    func testDoesNotRequireHorizontalScrollWhenFits() {
        let needsScroll = AdaptiveSizing.requiresHorizontalScroll(availableWidth: 350, itemCount: 5, spacing: 6, minSize: 20)
        XCTAssertFalse(needsScroll)
    }
}

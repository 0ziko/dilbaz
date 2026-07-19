import XCTest
import SwiftUI
import UIKit
@testable import Dilbaz

final class ColorHexTests: XCTestCase {
    func testHexInitializerProducesExpectedRGB() {
        let color = Color(hex: 0xFF6B4A)
        let uiColor = UIColor(color)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        XCTAssertEqual(r, 1.0, accuracy: 0.01)
        XCTAssertEqual(g, 0x6B / 255.0, accuracy: 0.01)
        XCTAssertEqual(b, 0x4A / 255.0, accuracy: 0.01)
    }
}

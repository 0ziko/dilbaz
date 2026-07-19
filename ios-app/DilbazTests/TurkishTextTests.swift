import XCTest
@testable import Dilbaz

final class TurkishTextTests: XCTestCase {
    func testTurkishUppercaseIcin() {
        XCTAssertEqual(TurkishText.uppercased("için", language: .tr), "İÇİN")
    }

    func testTurkishLowercaseIstanbul() {
        XCTAssertEqual(TurkishText.lowercased("İSTANBUL", language: .tr), "istanbul")
    }

    func testTurkishUppercaseIsik() {
        XCTAssertEqual(TurkishText.uppercased("ışık", language: .tr), "IŞIK")
    }

    func testTurkishLowercaseIzmir() {
        XCTAssertEqual(TurkishText.lowercased("İZMİR", language: .tr), "izmir")
    }

    func testTurkishNormalizedForMatchingPhrase() {
        XCTAssertEqual(
            TurkishText.normalizedForMatching("Allah bal mumu", language: .tr),
            "ALLAHBALMUMU"
        )
    }

    func testEnglishUppercaseThat() {
        XCTAssertEqual(TurkishText.uppercased("that", language: .en), "THAT")
    }
}

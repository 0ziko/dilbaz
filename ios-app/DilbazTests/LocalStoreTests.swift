import XCTest
@testable import Dilbaz

final class LocalStoreTests: XCTestCase {
    struct Dummy: Codable, Equatable {
        var value: Int
    }

    func testSaveAndLoadRoundTrip() async throws {
        let key = "test_dummy_\(UUID().uuidString)"
        let original = Dummy(value: 42)
        try await LocalStore.shared.save(original, forKey: key)
        let loaded = try await LocalStore.shared.load(Dummy.self, forKey: key)
        XCTAssertEqual(loaded, original)
    }

    func testLoadReturnsNilWhenMissing() async throws {
        let loaded = try await LocalStore.shared.load(Dummy.self, forKey: "definitely_missing_key")
        XCTAssertNil(loaded)
    }
}

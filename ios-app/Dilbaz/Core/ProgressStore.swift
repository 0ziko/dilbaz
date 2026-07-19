import Foundation
import Observation

@MainActor
@Observable
final class ProgressStore {
    static let storageKey = "user_progress"

    private(set) var progress = UserProgress()

    init() {
        Task { await loadFromDisk() }
    }

    func loadFromDisk() async {
        if let loaded = try? await LocalStore.shared.load(UserProgress.self, forKey: Self.storageKey) {
            progress = loaded
        }
    }

    func update(_ mutation: (inout UserProgress) -> Void) {
        mutation(&progress)
        let snapshot = progress
        Task {
            try? await LocalStore.shared.save(snapshot, forKey: Self.storageKey)
        }
    }
}

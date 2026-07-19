enum DifficultyTier: String {
    case kolay = "Kolay"
    case normal = "Normal"
    case zor = "Zor"
    case cokZor = "Çok Zor"

    static func forLetterCount(_ count: Int) -> DifficultyTier {
        switch count {
        case ..<8: return .kolay       // 4–7 harf
        case 8..<13: return .normal    // 8–12 harf
        case 13..<21: return .zor      // 13–20 harf
        default: return .cokZor        // 21+ harf
        }
    }
}

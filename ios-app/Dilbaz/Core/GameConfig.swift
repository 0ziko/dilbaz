import Foundation

struct LivesRange: Sendable {
    let minLength: Int
    let maxLength: Int
    let totalLives: Int
}

enum LivesConfig {
    static let table: [LivesRange] = [
        LivesRange(minLength: 4, maxLength: 5, totalLives: 6),
        LivesRange(minLength: 6, maxLength: 7, totalLives: 7),
        LivesRange(minLength: 8, maxLength: 9, totalLives: 8),
        LivesRange(minLength: 10, maxLength: 12, totalLives: 9),
        LivesRange(minLength: 13, maxLength: 15, totalLives: 10),
        LivesRange(minLength: 16, maxLength: 20, totalLives: 11),
        LivesRange(minLength: 21, maxLength: 30, totalLives: 13),
        LivesRange(minLength: 31, maxLength: 45, totalLives: 15),
        LivesRange(minLength: 46, maxLength: Int.max, totalLives: 18),
    ]

    static func lives(forLetterCount count: Int) -> Int {
        if let match = table.first(where: { count >= $0.minLength && count <= $0.maxLength }) {
            return match.totalLives
        }
        // Tablo aralığının dışında kalan (teorik olarak olmaması gereken, örn. 4'ten kısa) değerler
        // için en yakın uca sabitle (aşağı taşan -> ilk aralık, yukarı taşan -> son aralık).
        if count < table.first!.minLength { return table.first!.totalLives }
        return table.last!.totalLives
    }

    static let wrongLetterCost = 1
    static let wrongWordGuessCost = 2
}

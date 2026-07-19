import Foundation

struct PuzzleEntry: Codable, Identifiable, Hashable, Sendable {
    let id: String
    let text: String
    let letters: String
    let letterCount: Int
    let type: String  // "word" | "atasozu" | "deyim"
    let difficulty: Double
    let frequencyRank: Int?
    let frequencyCount: Int?
    let definition: String?
    let origin: String?

    var hintText: String {
        let uniqueLetterCount = Set(letters).count
        if uniqueLetterCount < letters.count {
            return "İçinde en az bir harf birden fazla kez geçiyor."
        } else {
            return "İçindeki tüm harfler birbirinden farklı."
        }
    }
}

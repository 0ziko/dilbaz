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
        switch type {
        case "atasozu", "deyim":
            return "Bu bir atasözü ya da deyim."
        default:
            if text.contains(" ") {
                return "Bu bir atasözü ya da deyim."
            }
            return "Bu tek bir kelime."
        }
    }
}

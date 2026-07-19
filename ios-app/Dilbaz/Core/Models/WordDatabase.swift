import Foundation

struct WordDatabase: Codable, Sendable {
    struct TRSection: Codable, Sendable {
        let words: [PuzzleEntry]
        let atasozu: [PuzzleEntry]
        let deyim: [PuzzleEntry]
    }
    struct ENSection: Codable, Sendable {
        let words: [PuzzleEntry]
    }

    let version: String
    let tr: TRSection
    let en: ENSection
    let categories: [String: [String]]
}

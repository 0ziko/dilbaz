import Foundation
import Observation

enum GameStatus: Sendable, Equatable {
    case playing
    case won
    case lost
}

enum LetterGuessResult: Sendable, Equatable {
    case correct
    case incorrect
    case alreadyGuessed
}

enum WordGuessLetterResult: Sendable, Equatable {
    case correctPosition
    case wrongPosition
    case notInWord
}

enum WordGuessFeedback: Sendable, Equatable {
    case correct
    case incorrect(positions: [WordGuessLetterResult])
}

@MainActor
@Observable
final class GameSession {
    let puzzle: PuzzleEntry
    let language: GameLanguage

    private(set) var totalLives: Int
    private(set) var remainingLives: Int
    private(set) var keyStates: [Character: KeyState] = [:]
    private(set) var revealedLetterSet: Set<Character> = []
    private(set) var status: GameStatus = .playing
    private(set) var lastWordGuessFeedback: WordGuessFeedback?
    private(set) var wrongLetterGuessCount: Int = 0
    private(set) var lastGuessedWord: String?
    private(set) var hintUsed: Bool = false

    private let normalizedFlatAnswer: String
    let segments: [String]

    init(puzzle: PuzzleEntry, language: GameLanguage) {
        self.puzzle = puzzle
        self.language = language
        self.normalizedFlatAnswer = puzzle.letters
        self.segments = puzzle.text.split(separator: " ").map {
            TurkishText.normalizedForMatching(String($0), language: language)
        }
        let lives = LivesConfig.lives(forLetterCount: puzzle.letterCount)
        self.totalLives = lives
        self.remainingLives = lives
    }

    /// Grid gösterimi: her segment (kelime), her harf açıksa Character, kapalıysa nil.
    var displaySegments: [[Character?]] {
        segments.map { segment in
            segment.map { revealedLetterSet.contains($0) ? $0 : nil }
        }
    }

    @discardableResult
    func guessLetter(_ letter: Character) -> LetterGuessResult {
        guard status == .playing else { return .alreadyGuessed }
        let normalized = TurkishText.uppercased(String(letter), language: language)
        guard let normalizedChar = normalized.first else { return .alreadyGuessed }
        guard keyStates[normalizedChar] == nil else { return .alreadyGuessed }

        if normalizedFlatAnswer.contains(normalizedChar) {
            keyStates[normalizedChar] = .correct
            revealedLetterSet.insert(normalizedChar)
            checkWinCondition()
            return .correct
        } else {
            keyStates[normalizedChar] = .incorrect
            wrongLetterGuessCount += 1
            spendLives(LivesConfig.wrongLetterCost)
            return .incorrect
        }
    }

    @discardableResult
    func guessFullWord(_ guess: String) -> WordGuessFeedback {
        guard status == .playing else { return .incorrect(positions: []) }
        let normalizedGuess = TurkishText.normalizedForMatching(guess, language: language)
        lastGuessedWord = normalizedGuess

        if normalizedGuess == normalizedFlatAnswer {
            revealedLetterSet = Set(normalizedFlatAnswer)
            status = .won
            let feedback = WordGuessFeedback.correct
            lastWordGuessFeedback = feedback
            return feedback
        }

        let positions = Self.wordleStyleFeedback(guess: normalizedGuess, answer: normalizedFlatAnswer)
        spendLives(LivesConfig.wrongWordGuessCost)
        let feedback = WordGuessFeedback.incorrect(positions: positions)
        lastWordGuessFeedback = feedback
        return feedback
    }

    private func spendLives(_ amount: Int) {
        remainingLives = max(0, remainingLives - amount)
        if remainingLives == 0 && status == .playing {
            status = .lost
            revealedLetterSet = Set(normalizedFlatAnswer)
        }
    }

    private func checkWinCondition() {
        if Set(normalizedFlatAnswer).isSubset(of: revealedLetterSet) {
            status = .won
        }
    }

    /// Standart iki geçişli Wordle algoritması (yinelenen harfleri doğru sayar).
    static func wordleStyleFeedback(guess: String, answer: String) -> [WordGuessLetterResult] {
        let guessChars = Array(guess)
        let answerChars = Array(answer)
        var result = [WordGuessLetterResult](repeating: .notInWord, count: guessChars.count)
        var answerUsed = [Bool](repeating: false, count: answerChars.count)

        for i in guessChars.indices where i < answerChars.count {
            if guessChars[i] == answerChars[i] {
                result[i] = .correctPosition
                answerUsed[i] = true
            }
        }
        for i in guessChars.indices where result[i] == .notInWord {
            if let matchIndex = answerChars.indices.first(where: { !answerUsed[$0] && answerChars[$0] == guessChars[i] }) {
                result[i] = .wrongPosition
                answerUsed[matchIndex] = true
            }
        }
        return result
    }

    /// Brief: "3. yanlıştan sonra kategorik ipucu (harf değil), ücretsiz."
    /// "Yanlış" burada yanlış HARF tahminini ifade ediyor (kelime tahmini değil).
    var isHintAvailable: Bool {
        status == .playing && wrongLetterGuessCount >= 3 && !hintUsed
    }

    @discardableResult
    func useHint() -> String? {
        guard isHintAvailable else { return nil }
        hintUsed = true
        return puzzle.hintText
    }
}

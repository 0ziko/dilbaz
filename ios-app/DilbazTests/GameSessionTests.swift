import XCTest
@testable import Dilbaz

@MainActor
final class GameSessionTests: XCTestCase {
    private func makeTestPuzzle(text: String, letters: String, letterCount: Int) -> PuzzleEntry {
        PuzzleEntry(
            id: "test_1", text: text, letters: letters, letterCount: letterCount,
            type: "word", difficulty: Double(letterCount) / 5.0,
            frequencyRank: nil, frequencyCount: nil, definition: nil, origin: nil
        )
    }

    func testCorrectLetterRevealsAllPositions() {
        // "KELİME" -> K,E,L,İ,M,E — "E" harfi 2. ve 6. konumda (0-indeksli: 1 ve 5).
        let puzzle = makeTestPuzzle(text: "kelime", letters: "KELİME", letterCount: 6)
        let session = GameSession(puzzle: puzzle, language: .tr)
        _ = session.guessLetter("e")
        let expected: [Character?] = [nil, "E", nil, nil, nil, "E"]
        XCTAssertEqual(session.displaySegments[0], expected)
    }

    func testWrongLetterCostsOneLife() {
        let puzzle = makeTestPuzzle(text: "kelime", letters: "KELİME", letterCount: 6)
        let session = GameSession(puzzle: puzzle, language: .tr)
        let startingLives = session.remainingLives
        _ = session.guessLetter("z")
        XCTAssertEqual(session.remainingLives, startingLives - 1)
    }

    func testWinConditionWhenAllLettersRevealed() {
        let puzzle = makeTestPuzzle(text: "ev", letters: "EV", letterCount: 2)
        let session = GameSession(puzzle: puzzle, language: .tr)
        _ = session.guessLetter("e")
        _ = session.guessLetter("v")
        XCTAssertEqual(session.status, .won)
    }

    func testWrongFullWordGuessCostsTwoLives() {
        let puzzle = makeTestPuzzle(text: "kelime", letters: "KELİME", letterCount: 6)
        let session = GameSession(puzzle: puzzle, language: .tr)
        let startingLives = session.remainingLives
        _ = session.guessFullWord("yanlis")
        XCTAssertEqual(session.remainingLives, startingLives - 2)
    }

    func testCorrectFullWordGuessWins() {
        let puzzle = makeTestPuzzle(text: "kelime", letters: "KELİME", letterCount: 6)
        let session = GameSession(puzzle: puzzle, language: .tr)
        _ = session.guessFullWord("kelime")
        XCTAssertEqual(session.status, .won)
    }

    func testLosesWhenLivesReachZero() {
        // "kedi" (K,E,D,İ) -> LivesConfig'e göre 4-5 harf aralığı = 6 hak.
        // Kelimede olmayan 6 farklı harfle yanlış tahmin yapıp hakları tüketelim.
        let puzzle = makeTestPuzzle(text: "kedi", letters: "KEDİ", letterCount: 4)
        let session = GameSession(puzzle: puzzle, language: .tr)
        let wrongLetters: [Character] = ["Z", "X", "Q", "W", "J", "F"]
        for letter in wrongLetters {
            _ = session.guessLetter(letter)
        }
        XCTAssertEqual(session.status, .lost)
        XCTAssertEqual(session.remainingLives, 0)
    }

    func testWordleFeedbackHandlesDuplicateLetters() {
        // answer: "ANNE" (A,N,N,E), guess: "NENE" (N,E,N,E)
        // index0 N vs A: yok (ama answer'da N var, henüz kullanılmamış -> wrongPosition)
        // index1 E vs N: yok, answer'daki tek E zaten index3'te doğru pozisyonla eşleşecek -> notInWord
        // index2 N vs N: correctPosition
        // index3 E vs E: correctPosition
        let feedback = GameSession.wordleStyleFeedback(guess: "NENE", answer: "ANNE")
        let expected: [WordGuessLetterResult] = [.wrongPosition, .notInWord, .correctPosition, .correctPosition]
        XCTAssertEqual(feedback, expected)
    }

    func testLivesConfigTable() {
        XCTAssertEqual(LivesConfig.lives(forLetterCount: 4), 6)
        XCTAssertEqual(LivesConfig.lives(forLetterCount: 5), 6)
        XCTAssertEqual(LivesConfig.lives(forLetterCount: 6), 7)
        XCTAssertEqual(LivesConfig.lives(forLetterCount: 50), 18)
        XCTAssertEqual(LivesConfig.lives(forLetterCount: 1000), 18)
    }
}

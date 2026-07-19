import SwiftUI

struct DailyClassicGameView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var session: GameSession
    private let language: GameLanguage
    let onBack: () -> Void

    @State private var isGuessInputVisible = false
    @State private var guessText = ""
    @State private var revealedHint: String?
    @State private var guessErrorMessage: String?

    init(language: GameLanguage = .tr, onBack: @escaping () -> Void) {
        self.language = language
        self.onBack = onBack
        let db = try! WordDatabaseLoader.load()
        let puzzle = db.dailyPuzzle(language: language, date: Date())
        _session = State(initialValue: GameSession(puzzle: puzzle, language: language))
    }

    private var difficultyTier: DifficultyTier { DifficultyTier.forLetterCount(session.puzzle.letterCount) }
    private var structuralLabel: String {
        session.segments.count > 1 ? "DEYİM · \(session.segments.count) KELİME" : "KELİME"
    }
    private var endMessage: String {
        if let definition = session.puzzle.definition {
            return "\"\(session.puzzle.text)\" — \(definition)"
        }
        return session.puzzle.text
    }

    var body: some View {
        VStack(spacing: 0) {
            HeroHeaderView(
                title: "Günlük Klasik Mod",
                subtitle: "\(session.puzzle.letterCount) harf · \(difficultyTier.rawValue)",
                badgeText: session.status == .lost ? "💔 Bozuldu" : "🔥 12", // GEÇİCİ: gerçek streak verisi ayrı adımda bağlanacak
                gradient: session.status == .lost ? DilbazGradient.muted : DilbazGradient.blue,
                onBack: handleBack
            )
            ScrollView {
                VStack(spacing: 14) {
                    Text(structuralLabel)
                        .font(.system(size: 9.5, weight: .bold, design: .rounded))
                        .tracking(1.0)
                        .foregroundStyle(DilbazColor.textMuted)

                    LetterGridView(
                        segments: session.displaySegments,
                        fillGradient: session.status == .lost ? DilbazGradient.muted : DilbazGradient.blue
                    )
                        .padding(.horizontal, 16)

                    if session.status == .playing || session.status == .lost || session.status == .won {
                        if case .incorrect(let positions) = session.lastWordGuessFeedback, let guessedWord = session.lastGuessedWord, session.status == .playing {
                            WordleFeedbackStripView(guessedWord: guessedWord, positions: positions)
                        }
                    }

                    if session.status == .playing {
                        LivesPillView(remaining: session.remainingLives, total: session.totalLives)

                        if isGuessInputVisible {
                            GuessInputRowView(text: $guessText) {
                                let strippedGuess = guessText.replacingOccurrences(of: " ", with: "")
                                guard strippedGuess.count == session.puzzle.letterCount else {
                                    guessErrorMessage = "Tam olarak \(session.puzzle.letterCount) harf yazmalısın (boşluksuz)."
                                    return
                                }
                                guessErrorMessage = nil
                                session.guessFullWord(guessText)
                                guessText = ""
                                isGuessInputVisible = false
                            }
                            if let guessErrorMessage {
                                Text(guessErrorMessage)
                                    .font(.system(size: 10.5, weight: .semibold, design: .rounded))
                                    .foregroundStyle(DilbazColor.pink2)
                            }
                        } else {
                            Button {
                                isGuessInputVisible = true
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: "pencil")
                                    Text("Kelimeyi Tahmin Et")
                                }
                                .font(.system(size: 13.5, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(DilbazGradient.orange)
                                .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
                            }
                        }

                        HintButtonView(state: hintState) {
                            revealedHint = session.useHint()
                        }

                        if let revealedHint {
                            Text("İpucu: \(revealedHint)")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundStyle(DilbazColor.pink2)
                                .multilineTextAlignment(.center)
                                .padding(9)
                                .background(DilbazColor.pink1.opacity(0.08))
                                .clipShape(RoundedRectangle(cornerRadius: 11, style: .continuous))
                                .overlay(RoundedRectangle(cornerRadius: 11, style: .continuous).stroke(DilbazColor.pink1, lineWidth: 1))
                        }

                        KeyboardView(
                            layout: .layout(for: session.language),
                            language: session.language,
                            keyStates: session.keyStates
                        ) { letter in
                            session.guessLetter(letter)
                        }
                        .frame(height: 150)
                    } else {
                        EndStateCardView(isWin: session.status == .won, message: endMessage)
                    }
                }
                .padding(.horizontal, 18)
                .padding(.top, 14)
                .padding(.bottom, 20)
            }
        }
        .background(DilbazColor.background.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }

    private var hintState: HintButtonState {
        if session.hintUsed { return .used }
        if session.isHintAvailable { return .active }
        return .locked(remainingWrongGuesses: max(0, 3 - session.wrongLetterGuessCount))
    }

    private func handleBack() {
        onBack()
        dismiss()
    }
}

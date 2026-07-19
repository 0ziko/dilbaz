import SwiftUI

struct GameTestView: View {
    @State private var session: GameSession
    @State private var wordGuessInput = ""
    private let language: GameLanguage

    init(language: GameLanguage = .tr) {
        self.language = language
        let db = try! WordDatabaseLoader.load()
        let puzzle = db.dailyPuzzle(language: language, date: Date())
        _session = State(initialValue: GameSession(puzzle: puzzle, language: language))
    }

    var body: some View {
        VStack(spacing: 16) {
            Text("Hak: \(session.remainingLives) / \(session.totalLives)")
                .font(.headline)
            Text("Durum: \(String(describing: session.status))")

            VStack(spacing: AdaptiveSizingConstants.boxSpacing) {
                ForEach(Array(session.displaySegments.enumerated()), id: \.offset) { _, segment in
                    GeometryReader { geometry in
                        let needsScroll = AdaptiveSizing.requiresHorizontalScroll(
                            availableWidth: geometry.size.width,
                            itemCount: segment.count,
                            spacing: AdaptiveSizingConstants.boxSpacing,
                            minSize: AdaptiveSizingConstants.boxMinSize
                        )
                        let boxSize = needsScroll
                            ? AdaptiveSizingConstants.boxMinSize
                            : AdaptiveSizing.itemSize(
                                availableWidth: geometry.size.width,
                                itemCount: segment.count,
                                spacing: AdaptiveSizingConstants.boxSpacing,
                                minSize: AdaptiveSizingConstants.boxMinSize,
                                maxSize: AdaptiveSizingConstants.boxMaxSize
                              )

                        Group {
                            if needsScroll {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    letterRow(segment: segment, boxSize: boxSize)
                                }
                            } else {
                                HStack {
                                    Spacer(minLength: 0)
                                    letterRow(segment: segment, boxSize: boxSize)
                                    Spacer(minLength: 0)
                                }
                            }
                        }
                    }
                    .frame(height: AdaptiveSizingConstants.boxMaxSize)
                }
            }
            .padding(.horizontal)

            KeyboardView(
                layout: .layout(for: session.language),
                language: session.language,
                keyStates: session.keyStates
            ) { letter in
                _ = session.guessLetter(letter)
            }
            .frame(height: 160)
            .padding(.horizontal)

            HStack {
                TextField("Tam kelimeyi yaz", text: $wordGuessInput)
                    .textFieldStyle(.roundedBorder)
                Button("Tahmin Et") {
                    _ = session.guessFullWord(wordGuessInput)
                    wordGuessInput = ""
                }
            }
            .padding(.horizontal)

            if let definition = session.puzzle.definition, session.status != .playing {
                Text(definition)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .padding()
            }
        }
        .padding(.top, 40)
    }

    @ViewBuilder
    private func letterRow(segment: [Character?], boxSize: CGFloat) -> some View {
        HStack(spacing: AdaptiveSizingConstants.boxSpacing) {
            ForEach(Array(segment.enumerated()), id: \.offset) { _, letter in
                Text(letter.map(String.init) ?? "_")
                    .font(.system(size: boxSize * 0.5, weight: .semibold))
                    .frame(width: boxSize, height: boxSize)
                    .border(Color.gray)
            }
        }
    }
}

#Preview {
    GameTestView()
}

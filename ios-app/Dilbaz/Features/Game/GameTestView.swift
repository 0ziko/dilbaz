import SwiftUI

struct GameTestView: View {
    @State private var session: GameSession
    @State private var wordGuessInput = ""

    init() {
        let db = try! WordDatabaseLoader.load()
        let puzzle = db.dailyPuzzle(language: .tr, date: Date())
        _session = State(initialValue: GameSession(puzzle: puzzle, language: .tr))
    }

    var body: some View {
        VStack(spacing: 16) {
            Text("Hak: \(session.remainingLives) / \(session.totalLives)")
                .font(.headline)
            Text("Durum: \(String(describing: session.status))")

            ForEach(Array(session.displaySegments.enumerated()), id: \.offset) { _, segment in
                HStack(spacing: 4) {
                    ForEach(Array(segment.enumerated()), id: \.offset) { _, letter in
                        Text(letter.map(String.init) ?? "_")
                            .frame(width: 28, height: 28)
                            .border(Color.gray)
                    }
                }
            }

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
}

#Preview {
    GameTestView()
}

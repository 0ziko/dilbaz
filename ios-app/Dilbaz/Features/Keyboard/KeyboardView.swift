import SwiftUI

struct KeyboardView: View {
    let layout: KeyboardLayout
    let language: GameLanguage
    let keyStates: [Character: KeyState]
    let onKeyTap: (Character) -> Void

    private let rowSpacing: CGFloat = 8

    var body: some View {
        GeometryReader { geometry in
            let maxCount = layout.maxRowKeyCount
            // AdaptiveSizing.itemSize ile aynı prensip (en kalabalık satır baz alınır, tüm satırlarda eşit tuş genişliği).
            let keyWidth = AdaptiveSizing.itemSize(
                availableWidth: geometry.size.width,
                itemCount: maxCount,
                spacing: AdaptiveSizingConstants.keySpacing,
                minSize: AdaptiveSizingConstants.keyMinSize,
                maxSize: AdaptiveSizingConstants.keyMaxSize
            )
            let keyHeight = keyWidth * 1.3

            VStack(spacing: rowSpacing) {
                ForEach(Array(layout.rows.enumerated()), id: \.offset) { _, row in
                    HStack {
                        Spacer(minLength: 0)
                        HStack(spacing: AdaptiveSizingConstants.keySpacing) {
                            ForEach(row, id: \.self) { letter in
                                KeyView(
                                    letter: letter,
                                    state: keyStates[letter] ?? .normal,
                                    width: keyWidth,
                                    height: keyHeight
                                ) {
                                    onKeyTap(letter)
                                }
                            }
                        }
                        Spacer(minLength: 0)
                    }
                }
            }
        }
        .frame(height: rowHeightEstimate)
    }

    private var rowHeightEstimate: CGFloat {
        // Kaba bir yükseklik tahmini (3 satır + spacing); gerçek boyut GeometryReader'dan geliyor.
        CGFloat(layout.rows.count) * 46 + CGFloat(layout.rows.count - 1) * rowSpacing
    }
}

#Preview("TR + EN Klavye") {
    let trStates: [Character: KeyState] = [
        "E": .correct,
        "R": .correct,
        "A": .incorrect,
        "Ş": .incorrect,
    ]
    let enStates: [Character: KeyState] = [
        "T": .correct,
        "H": .correct,
        "A": .incorrect,
        "X": .incorrect,
    ]

    VStack(spacing: 24) {
        Text("Türkçe Q")
            .font(.headline)
        KeyboardView(
            layout: .turkish,
            language: .tr,
            keyStates: trStates,
            onKeyTap: { _ in }
        )
        .frame(width: 380)

        Text("English QWERTY")
            .font(.headline)
        KeyboardView(
            layout: .english,
            language: .en,
            keyStates: enStates,
            onKeyTap: { _ in }
        )
        .frame(width: 380)
    }
    .padding()
}

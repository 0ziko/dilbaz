import SwiftUI

struct WordleFeedbackStripView: View {
    let guessedWord: String
    let positions: [WordGuessLetterResult]

    var body: some View {
        VStack(spacing: 6) {
            Text("SON TAHMİNİN")
                .font(.system(size: 9, weight: .bold, design: .rounded))
                .tracking(1.0)
                .foregroundStyle(DilbazColor.textMuted)
            HStack(spacing: 3) {
                ForEach(Array(zip(guessedWord, positions).enumerated()), id: \.offset) { _, pair in
                    let (letter, result) = pair
                    Text(String(letter))
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundStyle(result == .wrongPosition ? DilbazColor.textDark : .white)
                        .frame(width: 20, height: 20)
                        .background(color(for: result))
                        .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
                }
            }
        }
        .padding(9)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(Color(hex: 0xE7E4F4), lineWidth: 1))
    }

    private func color(for result: WordGuessLetterResult) -> Color {
        switch result {
        case .correctPosition: return Color(hex: 0x4FD1A5)
        case .wrongPosition: return Color(hex: 0xF4C95D)
        case .notInWord: return Color(hex: 0xC7C4D6)
        }
    }
}

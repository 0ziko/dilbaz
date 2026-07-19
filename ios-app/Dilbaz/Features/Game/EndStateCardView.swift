import SwiftUI

struct EndStateCardView: View {
    let isWin: Bool
    let message: String

    var body: some View {
        Text((isWin ? "🎉 Kazandın! " : "Bu sefer olmadı. ") + message)
            .font(.system(size: 12, weight: .semibold, design: .rounded))
            .foregroundStyle(DilbazColor.textMuted)
            .multilineTextAlignment(.center)
            .padding(12)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(Color(hex: 0xE7E4F4), lineWidth: 1))
    }
}

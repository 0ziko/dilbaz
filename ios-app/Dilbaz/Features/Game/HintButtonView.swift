import SwiftUI

enum HintButtonState {
    case locked(remainingWrongGuesses: Int)
    case active
    case used
}

struct HintButtonView: View {
    let state: HintButtonState
    let action: () -> Void

    var body: some View {
        Group {
            switch state {
            case .locked(let remaining):
                label("💡 İpucuya \(remaining) yanlış kaldı")
                    .foregroundStyle(DilbazColor.textMuted)
                    .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).strokeBorder(style: StrokeStyle(lineWidth: 1.6, dash: [5,4])).foregroundStyle(Color(hex: 0xD6D3E4)))
                    .background(Color.white.clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous)))
            case .active:
                Button(action: action) {
                    label("💡 İpucu Al")
                        .foregroundStyle(DilbazColor.pink2)
                }
                .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(DilbazColor.pink1, lineWidth: 1.5))
                .background(DilbazColor.pink1.opacity(0.08).clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous)))
            case .used:
                label("✓ İpucu Kullanıldı")
                    .foregroundStyle(DilbazColor.textMuted)
                    .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(Color(hex: 0xE1DEF0), lineWidth: 1.5))
                    .background(Color(hex: 0xF1EFF9).clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous)))
            }
        }
    }

    private func label(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 12.5, weight: .bold, design: .rounded))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 11)
    }
}

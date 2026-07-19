import SwiftUI
import UIKit

struct EndStateCardView: View {
    let isWin: Bool
    let message: String

    @State private var didAnimateIn = false

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: isWin ? "checkmark.seal.fill" : "cloud.rain.fill")
                .font(.system(size: 36))
                .foregroundStyle(isWin ? Color(hex: 0x4FD1A5) : DilbazColor.gray2)
                .scaleEffect(didAnimateIn ? 1 : 0.4)
                .opacity(didAnimateIn ? 1 : 0)

            Text((isWin ? "Kazandın! " : "Bu sefer olmadı. ") + message)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(DilbazColor.textMuted)
                .multilineTextAlignment(.center)
        }
        .padding(18)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(Color(hex: 0xE7E4F4), lineWidth: 1))
        .onAppear {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.6)) {
                didAnimateIn = true
            }
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(isWin ? .success : .error)
        }
    }
}

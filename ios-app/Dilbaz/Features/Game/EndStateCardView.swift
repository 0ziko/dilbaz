import SwiftUI
import UIKit

struct EndStateCardView: View {
    let isWin: Bool
    let message: String

    @State private var didAnimateIn = false

    private var headline: String { isWin ? "Kazandın!" : "Bu sefer olmadı" }
    private var headlineColor: Color { isWin ? Color(hex: 0x2FA97F) : DilbazColor.gray2 }

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: isWin ? "checkmark.seal.fill" : "cloud.rain.fill")
                .font(.system(size: 38))
                .foregroundStyle(isWin ? Color(hex: 0x4FD1A5) : DilbazColor.gray2)
                .scaleEffect(didAnimateIn ? 1 : 0.4)
                .opacity(didAnimateIn ? 1 : 0)

            Text(headline)
                .font(.system(size: 21, weight: .heavy, design: .rounded))
                .foregroundStyle(headlineColor)
                .scaleEffect(didAnimateIn ? 1 : 0.7)
                .opacity(didAnimateIn ? 1 : 0)

            Text(message)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(DilbazColor.textMuted)
                .multilineTextAlignment(.center)
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(Color(hex: 0xE7E4F4), lineWidth: 1))
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.55)) {
                didAnimateIn = true
            }
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(isWin ? .success : .error)
        }
    }
}

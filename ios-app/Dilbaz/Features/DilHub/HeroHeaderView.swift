import SwiftUI

struct HeroHeaderView: View {
    let title: String
    let subtitle: String
    let badgeText: String
    let gradient: LinearGradient
    let onBack: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 34, height: 34)
                    .background(Color.white.opacity(0.22))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 21, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Text(subtitle)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.9))
            }
            Spacer()
            Text(badgeText) // GEÇİCİ: sabit örnek streak değeri
                .font(.system(size: 11.5, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(Color.white.opacity(0.22))
                .clipShape(Capsule())
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 22)
        .background(gradient)
        .clipShape(RoundedCorner(radius: 28, corners: [.bottomLeft, .bottomRight]))
    }
}

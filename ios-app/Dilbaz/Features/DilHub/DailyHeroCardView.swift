import SwiftUI

struct DailyHeroCardView: View {
    let onStart: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("GÜNLÜK KLASİK MOD")
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .tracking(1.2)
                .foregroundStyle(.white.opacity(0.85))
            Text("Bugünün bulmacası hazır")
                .font(.system(size: 27, weight: .heavy, design: .rounded))
                .foregroundStyle(.white)
            Text("Herkese aynı kelime geliyor. Harfleri tek tek aç, istersen tahminini erken dene — ama yanlış tahmin daha pahalıya patlar.")
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(.white.opacity(0.92))
                .frame(maxWidth: 380, alignment: .leading)

            HStack(spacing: 8) {
                Image(systemName: "flame.fill")
                Text("12 gün seri") // GEÇİCİ: gerçek streak verisi ayrı adımda bağlanacak
            }
            .font(.system(size: 13, weight: .bold, design: .rounded))
            .foregroundStyle(.white)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(Color.white.opacity(0.22))
            .clipShape(Capsule())

            Button(action: onStart) {
                HStack(spacing: 8) {
                    Image(systemName: "pencil")
                    Text("Bugünün Bulmacasını Aç")
                }
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .padding(.horizontal, 22)
                .padding(.vertical, 13)
                .background(DilbazGradient.orange)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .shadow(color: DilbazColor.orange2.opacity(0.5), radius: 12, x: 0, y: 8)
            }
            .buttonStyle(.plain)
        }
        .padding(34)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(DilbazGradient.blue)
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
        .shadow(color: DilbazColor.blue2.opacity(0.4), radius: 30, x: 0, y: 16)
        .padding(36)
    }
}

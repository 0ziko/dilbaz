import SwiftUI

struct ModeCardView: View {
    let mode: DilHubMode

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.white.opacity(0.28))
                    .frame(width: 42, height: 42)
                Image(systemName: mode.iconName)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(mode.rawValue)
                    .font(.system(size: 15.5, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Text(mode.subtitle)
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.9))
            }
            Spacer()
            Text(mode.placeholderStat)
                .font(.system(size: 10.5, weight: .bold, design: .rounded))
                .multilineTextAlignment(.trailing)
                .foregroundStyle(.white)
                .lineLimit(2)
        }
        .padding(16)
        .background(mode.gradient)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: .black.opacity(0.18), radius: 14, x: 0, y: 10)
    }
}

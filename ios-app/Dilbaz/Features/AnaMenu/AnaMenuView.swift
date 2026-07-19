import SwiftUI

struct AnaMenuView: View {
    let onSelectLanguage: (GameLanguage) -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 40)
            VStack(spacing: 6) {
                Text("TÜRKÇE & İNGİLİZCE KELİME OYUNU")
                    .font(.system(size: 10.5, weight: .bold, design: .rounded))
                    .tracking(1.4)
                    .foregroundStyle(DilbazColor.textMuted)
                Text("Dilbaz")
                    .font(.system(size: 38, weight: .heavy, design: .rounded))
                    .foregroundStyle(DilbazColor.textDark)
                Text("Harfleri avla, kelimeyi bul")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(DilbazColor.textMuted)
            }
            Spacer()
            VStack(spacing: 16) {
                LangCardView(
                    code: "T", name: "Türkçe", subtitle: "Ana dilinde harf avına çık",
                    gradient: DilbazGradient.violet
                ) { onSelectLanguage(.tr) }

                LangCardView(
                    code: "E", name: "English", subtitle: "Practice English, one letter at a time",
                    gradient: DilbazGradient.teal
                ) { onSelectLanguage(.en) }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 28)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DilbazColor.background.ignoresSafeArea())
    }
}

private struct LangCardView: View {
    let code: String
    let name: String
    let subtitle: String
    let gradient: LinearGradient
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.white.opacity(0.25))
                        .frame(width: 52, height: 52)
                    Text(code)
                        .font(.system(size: 20, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white)
                }
                VStack(alignment: .leading, spacing: 3) {
                    Text(name)
                        .font(.system(size: 19, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    Text(subtitle)
                        .font(.system(size: 11.5, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.92))
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white.opacity(0.9))
            }
            .padding(20)
            .background(gradient)
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .shadow(color: .black.opacity(0.18), radius: 16, x: 0, y: 12)
        }
        .buttonStyle(.plain)
    }
}

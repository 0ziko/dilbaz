import SwiftUI

struct DilHubView: View {
    let language: GameLanguage
    let onBack: () -> Void

    private var languageTitle: String { language == .tr ? "Türkçe" : "English" }

    private var dateText: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: language == .tr ? "tr_TR" : "en_US")
        formatter.dateFormat = "d MMMM yyyy · EEEE"
        return formatter.string(from: Date())
    }

    var body: some View {
        VStack(spacing: 0) {
            HeroHeaderView(
                title: languageTitle,
                subtitle: dateText,
                badgeText: "🔥 12",
                gradient: DilbazGradient.blue,
                onBack: onBack
            )
            ScrollView {
                VStack(spacing: 14) {
                    ForEach(DilHubMode.allCases) { mode in
                        NavigationLink(value: mode) {
                            ModeCardView(mode: mode)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(20)
            }
        }
        .background(DilbazColor.background.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }
}

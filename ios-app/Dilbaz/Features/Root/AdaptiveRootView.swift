import SwiftUI

/// Faz 0 — çoklu platform adaptif yerleşim temeli.
/// Dar ekran (iPhone, split iPad) -> tek sütun.
/// Geniş ekran (iPad tam ekran, Mac Catalyst) -> NavigationSplitView
/// (sol: mod kenar çubuğu, sağ: seçili oyun).
struct AdaptiveRootView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var selectedMode: TestModePlaceholder? = .dailyClassic

    var body: some View {
        Group {
            if horizontalSizeClass == .compact {
                NarrowRootView()
            } else {
                WideRootView(selectedMode: $selectedMode)
            }
        }
    }
}

/// GEÇİCİ yer tutucu — Faz 1'de gerçek Dil Hub mod listesiyle değiştirilecek.
enum TestModePlaceholder: String, CaseIterable, Identifiable {
    case dailyClassic = "Günlük Klasik Mod"
    case category = "Kategori Modu"
    case duel = "Düello Modu"
    case stats = "İstatistikler"

    var id: String { rawValue }
}

private struct NarrowRootView: View {
    var body: some View {
        GameTestView()
    }
}

private struct WideRootView: View {
    @Binding var selectedMode: TestModePlaceholder?

    var body: some View {
        NavigationSplitView {
            List(TestModePlaceholder.allCases, selection: $selectedMode) { mode in
                Text(mode.rawValue).tag(mode)
            }
            .navigationTitle("Dilbaz")
        } detail: {
            // Faz 0'da sadece "Günlük Klasik Mod" GameTestView'e bağlı;
            // diğer modlar Faz 1'de gerçek ekranlarla değiştirilecek.
            if selectedMode == .dailyClassic {
                GameTestView()
            } else {
                ContentUnavailableView(
                    selectedMode?.rawValue ?? "Bir mod seç",
                    systemImage: "hourglass"
                )
            }
        }
    }
}

#Preview("Dar Ekran") {
    NarrowRootView()
}

#Preview("Geniş Ekran") {
    WideRootView(selectedMode: .constant(.dailyClassic))
}

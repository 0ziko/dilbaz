import SwiftUI

/// Faz 0 — çoklu platform adaptif yerleşim temeli.
/// Dar ekran (iPhone, split iPad) -> tek sütun NavigationStack.
/// Geniş ekran (iPad tam ekran, Mac Catalyst) -> NavigationSplitView.
struct AdaptiveRootView: View {
    let language: GameLanguage
    let onChangeLanguage: () -> Void

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var body: some View {
        Group {
            if horizontalSizeClass == .compact {
                NarrowRootView(language: language, onChangeLanguage: onChangeLanguage)
            } else {
                WideRootView(language: language, onChangeLanguage: onChangeLanguage)
            }
        }
    }
}

private struct NarrowRootView: View {
    let language: GameLanguage
    let onChangeLanguage: () -> Void

    var body: some View {
        NavigationStack {
            DilHubView(language: language, onBack: onChangeLanguage)
                .navigationDestination(for: DilHubMode.self) { mode in
                    if mode == .dailyClassic {
                        GameTestView(language: language)
                    } else {
                        ContentUnavailableView(mode.rawValue, systemImage: mode.iconName)
                    }
                }
        }
    }
}

private struct WideRootView: View {
    let language: GameLanguage
    let onChangeLanguage: () -> Void

    @State private var selectedMode: DilHubMode? = .dailyClassic
    @State private var showDailyGame = false

    var body: some View {
        NavigationSplitView {
            List(DilHubMode.allCases, selection: $selectedMode) { mode in
                HStack(spacing: 10) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 9, style: .continuous)
                            .fill(mode.gradient)
                            .frame(width: 30, height: 30)
                        Image(systemName: mode.iconName)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.white)
                    }
                    Text(mode.rawValue)
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                }
                .tag(mode)
            }
            .listStyle(.sidebar)
            .navigationTitle("Dilbaz")
            .toolbar {
                ToolbarItem(placement: .navigation) {
                    Button("Dil Değiştir", action: onChangeLanguage)
                }
            }
        } detail: {
            switch selectedMode {
            case .dailyClassic:
                if showDailyGame {
                    GameTestView(language: language)
                } else {
                    DailyHeroCardView { showDailyGame = true }
                }
            case .some(let mode):
                ContentUnavailableView(mode.rawValue, systemImage: mode.iconName)
            case .none:
                ContentUnavailableView("Bir mod seç", systemImage: "hand.tap")
            }
        }
        .onChange(of: selectedMode) { _, _ in showDailyGame = false }
    }
}

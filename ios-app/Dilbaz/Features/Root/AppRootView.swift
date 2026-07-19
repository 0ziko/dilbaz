import SwiftUI

/// Uygulamanın en üst seviye akışı: dil seçilmediyse Ana Menü, seçildiyse Dil Hub + moda.
struct AppRootView: View {
    @State private var selectedLanguage: GameLanguage?

    var body: some View {
        if let language = selectedLanguage {
            AdaptiveRootView(language: language) {
                selectedLanguage = nil
            }
        } else {
            AnaMenuView { language in
                selectedLanguage = language
            }
        }
    }
}

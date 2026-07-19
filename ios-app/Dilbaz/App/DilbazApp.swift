import SwiftUI

@main
struct DilbazApp: App {
    var body: some Scene {
        WindowGroup {
            // GEÇİCİ: adaptif yerleşim iskeletini test etmek için. Gerçek Dil Hub navigasyonu ayrı bir promptta gelecek.
            AdaptiveRootView()
        }
    }
}

struct ContentView: View {
    var body: some View {
        VStack(spacing: 12) {
            Text("Dilbaz")
                .font(.largeTitle.bold())
            Text("Proje iskeleti hazır — oyun ekranları sıradaki adımlarda gelecek.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
    }
}

#Preview {
    ContentView()
}

import SwiftUI

struct KeyView: View {
    let letter: Character
    let state: KeyState
    let width: CGFloat
    let height: CGFloat
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(String(letter))
                .font(.system(size: max(12, width * 0.42), weight: .semibold))
                .frame(width: width, height: height)
                .background(backgroundColor)
                .foregroundStyle(foregroundColor)
                .clipShape(RoundedRectangle(cornerRadius: 6))
        }
        .disabled(state.isDisabled)
        .buttonStyle(.plain)
    }

    private var backgroundColor: Color {
        switch state {
        case .normal: return Color(.secondarySystemFill)
        case .correct: return .green
        case .incorrect: return DilbazColor.wrongKeyBackground
        }
    }

    private var foregroundColor: Color {
        switch state {
        case .normal: return .primary
        case .correct: return .white
        case .incorrect: return DilbazColor.wrongKeyText
        }
    }
}

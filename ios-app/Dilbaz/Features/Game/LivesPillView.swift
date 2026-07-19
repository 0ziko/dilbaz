import SwiftUI

struct LivesPillView: View {
    let remaining: Int
    let total: Int

    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: "bolt.fill")
                .font(.system(size: 11, weight: .bold))
            Text("\(remaining) / \(total) hak kaldı")
                .font(.system(size: 11, weight: .bold, design: .rounded))
        }
        .foregroundStyle(DilbazColor.textDark)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.white)
        .clipShape(Capsule())
        .overlay(Capsule().stroke(Color(hex: 0xE7E4F4), lineWidth: 1))
    }
}

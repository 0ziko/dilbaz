import SwiftUI

struct GuessInputRowView: View {
    @Binding var text: String
    let onSubmit: () -> Void

    var body: some View {
        HStack(spacing: 6) {
            TextField("Tam kelimeyi yaz", text: $text)
                .font(.system(size: 13, design: .rounded))
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(DilbazColor.orange2, lineWidth: 1.6))
                .onSubmit(onSubmit)

            Button(action: onSubmit) {
                Image(systemName: "checkmark")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 38, height: 38)
                    .background(DilbazGradient.orange)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
        }
    }
}

import SwiftUI

struct LetterGridView: View {
    let segments: [[Character?]]
    var fillGradient: LinearGradient = DilbazGradient.blue

    var body: some View {
        VStack(spacing: AdaptiveSizingConstants.boxSpacing) {
            ForEach(Array(segments.enumerated()), id: \.offset) { _, segment in
                GeometryReader { geometry in
                    let needsScroll = AdaptiveSizing.requiresHorizontalScroll(
                        availableWidth: geometry.size.width,
                        itemCount: segment.count,
                        spacing: AdaptiveSizingConstants.boxSpacing,
                        minSize: AdaptiveSizingConstants.boxMinSize
                    )
                    let boxSize = needsScroll
                        ? AdaptiveSizingConstants.boxMinSize
                        : AdaptiveSizing.itemSize(
                            availableWidth: geometry.size.width,
                            itemCount: segment.count,
                            spacing: AdaptiveSizingConstants.boxSpacing,
                            minSize: AdaptiveSizingConstants.boxMinSize,
                            maxSize: AdaptiveSizingConstants.boxMaxSize
                          )
                    Group {
                        if needsScroll {
                            ScrollView(.horizontal, showsIndicators: false) {
                                letterRow(segment: segment, boxSize: boxSize)
                            }
                        } else {
                            HStack {
                                Spacer(minLength: 0)
                                letterRow(segment: segment, boxSize: boxSize)
                                Spacer(minLength: 0)
                            }
                        }
                    }
                }
                .frame(height: AdaptiveSizingConstants.boxMaxSize)
            }
        }
    }

    @ViewBuilder
    private func letterRow(segment: [Character?], boxSize: CGFloat) -> some View {
        HStack(spacing: AdaptiveSizingConstants.boxSpacing) {
            ForEach(Array(segment.enumerated()), id: \.offset) { _, letter in
                ZStack {
                    RoundedRectangle(cornerRadius: boxSize * 0.24, style: .continuous)
                        .fill(letter != nil ? AnyShapeStyle(fillGradient) : AnyShapeStyle(Color.white))
                    if letter == nil {
                        RoundedRectangle(cornerRadius: boxSize * 0.24, style: .continuous)
                            .stroke(Color(hex: 0xE1DEF0), lineWidth: 1.3)
                    }
                    if let letter {
                        Text(String(letter))
                            .font(.system(size: boxSize * 0.46, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                    }
                }
                .frame(width: boxSize, height: boxSize)
            }
        }
    }
}

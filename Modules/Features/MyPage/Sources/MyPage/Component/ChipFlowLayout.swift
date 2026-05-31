import SwiftUI

struct ChipFlowLayout: Layout {
    var spacing: CGFloat = 8

    struct Cache {
        var frames: [CGRect] = []
        var size: CGSize = .zero
    }

    func makeCache(subviews: Subviews) -> Cache { Cache() }

    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout Cache
    ) -> CGSize {
        let maxWidth = proposal.width ?? proposal.replacingUnspecifiedDimensions().width

        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var frames: [CGRect] = []

        for view in subviews {
            var size = view.sizeThatFits(.unspecified)
            size.width = min(size.width, maxWidth)
            if x > 0, x + size.width > maxWidth {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            frames.append(CGRect(x: x, y: y, width: size.width, height: size.height))
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }

        let totalHeight = y + rowHeight
        let result = CGSize(width: maxWidth, height: totalHeight)
        cache.frames = frames
        cache.size = result
        return result
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout Cache
    ) {
        for (index, view) in subviews.enumerated() {
            guard index < cache.frames.count else { continue }
            let frame = cache.frames[index].offsetBy(dx: bounds.minX, dy: bounds.minY)
            view.place(
                at: CGPoint(x: frame.minX, y: frame.minY),
                proposal: ProposedViewSize(width: frame.width, height: frame.height)
            )
        }
    }
}

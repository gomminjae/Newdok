import SwiftUI
import UIKit
import DesignSystem

struct FontSizeControlView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var fontSize: CGFloat

    private let minFontSize: CGFloat = 15
    private let maxFontSize: CGFloat = 25

    private var minusActive: Bool { fontSize > minFontSize }
    private var plusActive: Bool { fontSize < maxFontSize }

    var body: some View {
        VStack(spacing: 0) {
            Capsule()
                .frame(width: 40, height: 5)
                .foregroundColor(Color.gray.opacity(0.5))
                .padding(.top, 20)

            HStack {
                Text("글자 크기")
                    .font(.hanSansNeo(20, .bold))
                    .foregroundColor(.black)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(asset: DesignSystemAsset.lineClose)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)

            VStack(spacing: 20) {
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text("\(Int(fontSize))")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.black)
                    Text("pt")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.black)
                }
                .padding(.top, 24)

                VStack(spacing: 4) {
                    HStack(alignment: .center, spacing: 12) {
                        fontSizeButton(systemName: "minus", isActive: minusActive) {
                            if fontSize > minFontSize { fontSize -= 1 }
                        }

                        BorderedThumbSlider(value: $fontSize, range: minFontSize...maxFontSize, step: 1)

                        fontSizeButton(systemName: "plus", isActive: plusActive) {
                            if fontSize < maxFontSize { fontSize += 1 }
                        }
                    }

                    HStack {
                        Text("\(Int(minFontSize))pt")
                            .font(.hanSansNeo(12, .medium))
                            .foregroundColor(Color.captionAssistive)
                        Spacer()
                        Text("\(Int(maxFontSize))pt")
                            .font(.hanSansNeo(12, .medium))
                            .foregroundColor(Color.captionAssistive)
                    }
                    .padding(.horizontal, 36 + 12)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 28)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.white)
        .presentationCornerRadius(36)
        .presentationDetents([.height(280)])
        .presentationDragIndicator(.hidden)
        .safeAreaInset(edge: .bottom) {
            Color.clear.frame(height: 6)
        }
    }

    @ViewBuilder
    private func fontSizeButton(systemName: String, isActive: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .renderingMode(.template)
                .font(.system(size: 16, weight: .medium))
                .frame(width: 36, height: 36)
                .overlay(
                    RoundedRectangle(cornerRadius: 10).stroke(Color.graySoft, lineWidth: 1.5)
                )
        }
        .buttonStyle(PlainButtonStyle())
        .foregroundColor(isActive ? Color.primaryNormal : Color.graySoft)
    }
}

// MARK: - Custom Track Slider

private class TrackSlider: UISlider {
    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.trackRect(forBounds: bounds)
        rect.size.height = 6
        rect.origin.y = bounds.midY - 3
        return rect
    }
}

// MARK: - Bordered Thumb Slider

private struct BorderedThumbSlider: UIViewRepresentable {
    @Binding var value: CGFloat
    let range: ClosedRange<CGFloat>
    let step: CGFloat

    func makeUIView(context: Context) -> UISlider {
        let slider = TrackSlider()
        slider.minimumValue = Float(range.lowerBound)
        slider.maximumValue = Float(range.upperBound)
        slider.value = Float(value)
        slider.minimumTrackTintColor = UIColor(red: 40/255, green: 102/255, blue: 211/255, alpha: 1)
        slider.maximumTrackTintColor = UIColor.systemGray4
        let thumb = makeThumbImage()
        slider.setThumbImage(thumb, for: .normal)
        slider.setThumbImage(thumb, for: .highlighted)
        slider.addTarget(context.coordinator, action: #selector(Coordinator.valueChanged(_:)), for: .valueChanged)
        return slider
    }

    func updateUIView(_ uiView: UISlider, context: Context) {
        let stepped = Float(round(value / step) * step)
        if uiView.value != stepped { uiView.value = stepped }
    }

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    private func makeThumbImage() -> UIImage {
        let size = CGSize(width: 28, height: 20)
        let cornerRadius: CGFloat = 8
        let borderWidth: CGFloat = 2
        let borderColor = UIColor(red: 40/255, green: 102/255, blue: 211/255, alpha: 1)
        return UIGraphicsImageRenderer(size: size).image { _ in
            let fillRect = CGRect(origin: .zero, size: size).insetBy(dx: borderWidth / 2, dy: borderWidth / 2)
            UIColor.white.setFill()
            UIBezierPath(roundedRect: fillRect, cornerRadius: cornerRadius - borderWidth / 2).fill()
            borderColor.setStroke()
            let borderPath = UIBezierPath(roundedRect: fillRect, cornerRadius: cornerRadius - borderWidth / 2)
            borderPath.lineWidth = borderWidth
            borderPath.stroke()
        }
    }

    @MainActor
    class Coordinator: NSObject {
        let parent: BorderedThumbSlider
        init(_ parent: BorderedThumbSlider) { self.parent = parent }

        @objc func valueChanged(_ slider: UISlider) {
            let stepped = round(slider.value / Float(parent.step)) * Float(parent.step)
            parent.value = CGFloat(stepped)
        }
    }
}

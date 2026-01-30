import SwiftUI
import AppKit

struct ContentView: View {
    @State private var refractionIntensity: Double = 0.5
    @State private var edgeWidth: Double = 40.0

    var body: some View {
        VStack(spacing: 24) {
            Text("Liquid Glass")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.6), radius: 3, x: 0, y: 2)

            Text("Edge refraction demo")
                .font(.title3)
                .foregroundStyle(.white.opacity(0.9))
                .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 1)

            // Buttons with Apple's glassEffect
            HStack(spacing: 16) {
                Image(systemName: "drop.fill")
                    .font(.title)
                    .foregroundStyle(.white)
                    .frame(width: 50, height: 50)
                    .glassEffect(.clear.interactive(), in: .circle)

                Image(systemName: "sparkles")
                    .font(.title)
                    .foregroundStyle(.white)
                    .frame(width: 50, height: 50)
                    .glassEffect(.clear.interactive(), in: .circle)

                Image(systemName: "wand.and.stars")
                    .font(.title)
                    .foregroundStyle(.white)
                    .frame(width: 50, height: 50)
                    .glassEffect(.clear.interactive(), in: .circle)
            }

            Spacer().frame(height: 20)

            // Refraction intensity slider
            SliderControl(label: "Refraction", value: $refractionIntensity, range: 0.0...1.0)

            // Edge width slider
            SliderControl(label: "Edge Width", value: $edgeWidth, range: 10.0...80.0, format: "%.0fpx")
        }
        .padding(50)
        .frame(minWidth: 440, minHeight: 400)
        .glassEffect(.clear, in: RoundedRectangle(cornerRadius: 24))
        .background(WindowDragArea())
    }
}

// Reusable slider control
struct SliderControl: View {
    var label: String
    @Binding var value: Double
    var range: ClosedRange<Double>
    var format: String = "%.0f%%"

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("\(label): \(String(format: format, format.contains("%%") ? value * 100 : value))")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.9))
                .shadow(color: .black.opacity(0.5), radius: 1, x: 0, y: 1)
            Slider(value: $value, in: range)
                .tint(.white)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(.white.opacity(0.3), lineWidth: 1)
        )
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.white.opacity(0.08))
        )
    }
}

struct WindowDragArea: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        let view = WindowDragView()
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {}
}

class WindowDragView: NSView {
    override func mouseDown(with event: NSEvent) {
        window?.performDrag(with: event)
    }
}

#Preview {
    ContentView()
}

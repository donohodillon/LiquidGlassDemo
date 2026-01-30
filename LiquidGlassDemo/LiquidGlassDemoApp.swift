import SwiftUI

@main
struct LiquidGlassDemoApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .background(WindowConfigurator())
        }
        .windowStyle(.plain)
    }
}

// Configure NSWindow properties
struct WindowConfigurator: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            if let window = view.window {
                window.isMovableByWindowBackground = true
                window.titlebarAppearsTransparent = true
                window.backgroundColor = .clear
            }
        }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {}
}

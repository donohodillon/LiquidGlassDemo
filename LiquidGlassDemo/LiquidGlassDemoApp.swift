import SwiftUI
import AppKit

@main
struct LiquidGlassDemoApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
                .background(WindowConfigurator())
        }
        .windowStyle(.plain)
    }
}

// App delegate to ensure proper window behavior
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Ensure the app activates properly
        NSApp.activate(ignoringOtherApps: true)
    }

    func applicationDidBecomeActive(_ notification: Notification) {
        // Make sure main window is key
        if let window = NSApp.windows.first {
            window.makeKey()
        }
    }
}

// Configure NSWindow properties
struct WindowConfigurator: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        let view = KeyableView()
        DispatchQueue.main.async {
            if let window = view.window {
                window.isMovableByWindowBackground = true
                window.titlebarAppearsTransparent = true
                window.backgroundColor = .clear
                // Critical: Make window accept keyboard input
                window.makeKey()
                window.makeFirstResponder(nil)
            }
        }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        // Ensure window stays key when view updates
        DispatchQueue.main.async {
            nsView.window?.makeKey()
        }
    }
}

// Custom NSView that accepts first responder
class KeyableView: NSView {
    override var acceptsFirstResponder: Bool { true }
    override func becomeFirstResponder() -> Bool { true }
}

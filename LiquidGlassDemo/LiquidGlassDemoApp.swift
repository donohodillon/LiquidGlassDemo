import SwiftUI
import AppKit

@main
struct LiquidGlassDemoApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
                .background(WindowAccessor())
        }
        .windowStyle(.plain)
    }
}

// App delegate to ensure proper window behavior
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.activate(ignoringOtherApps: true)
    }

    func applicationDidBecomeActive(_ notification: Notification) {
        // Force window to be key and accept input
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if let window = NSApp.windows.first {
                window.makeKey()
                window.makeMain()
            }
        }
    }
}

// Access and configure the NSWindow for keyboard input with plain style
struct WindowAccessor: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        let view = KeyInputView()
        DispatchQueue.main.async {
            guard let window = view.window else { return }

            // Make window transparent
            window.isOpaque = false
            window.backgroundColor = .clear
            window.isMovableByWindowBackground = true
            window.titlebarAppearsTransparent = true

            // Critical: These settings allow keyboard input in plain windows
            window.styleMask.insert(.titled)  // Hidden but allows key window
            window.titleVisibility = .hidden
            window.titlebarAppearsTransparent = true

            // Force it to be the key window
            window.makeKey()
            window.makeMain()

            print("DEBUG: Window configured for keyboard input")
        }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {}
}

class KeyInputView: NSView {
    override var acceptsFirstResponder: Bool { true }

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        window?.makeKey()
    }
}

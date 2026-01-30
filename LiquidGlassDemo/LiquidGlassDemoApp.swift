import SwiftUI

@main
struct LiquidGlassDemoApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowStyle(.plain) // Removes default chrome for custom glass look
    }
}

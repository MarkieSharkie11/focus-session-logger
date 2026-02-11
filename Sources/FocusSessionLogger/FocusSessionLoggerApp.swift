import SwiftUI

@main
struct FocusSessionLoggerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var sessionManager = SessionManager()

    var body: some Scene {
        MenuBarExtra {
            PopoverContentView(sessionManager: sessionManager)
                .frame(width: 320)
        } label: {
            Label(
                sessionManager.state == .idle ? "" : sessionManager.formattedTimeRemaining,
                systemImage: "timer"
            )
            .monospacedDigit()
        }
        .menuBarExtraStyle(.window)
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NotificationManager.shared.requestPermission()
    }
}

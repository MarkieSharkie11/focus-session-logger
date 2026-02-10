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
            if sessionManager.state == .idle {
                Image(systemName: "timer")
            } else {
                Text(sessionManager.formattedTimeRemaining)
                    .monospacedDigit()
            }
        }
        .menuBarExtraStyle(.window)
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NotificationManager.shared.requestPermission()
    }
}

import SwiftUI
import MenuBarAppUI
import PomodoroTimerCore
import PomodoroSettings // Import PomodoroSettings

@main
struct PomodoroMenuBarAppApp: App {
    @State var settingsManager: SettingsManager
    @State private var pomodoroTimer: PomodoroTimer
    
    @Environment(\.openWindow) private var openWindow

    init() {
        let manager = SettingsManager()
        _settingsManager = State(initialValue: manager)
        _pomodoroTimer = State(initialValue: PomodoroTimer(settingsManager: manager))
    }

    var body: some Scene {
        MenuBarExtra {
            // Main content of the menu bar popover
            PomodoroTimerView(pomodoroTimer: pomodoroTimer)
            
            // Add a separator and a Settings button
            Divider()
            
            Button("Settings...") {
                NSApp.activate(ignoringOtherApps: true) // Bring app to foreground
                openWindow(id: "settings")
            }
            .keyboardShortcut(",") // Common shortcut for settings
            
            Divider()
            
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q")
            
        } label: {
            // Display timer remaining or a static icon
            if pomodoroTimer.state == .running || pomodoroTimer.state == .paused {
                Text(timeString(from: pomodoroTimer.timeRemaining))
            } else {
                Image(systemName: "hourglass")
            }
        }
        .menuBarExtraStyle(.window) // Makes it behave like a popover rather than a menu
        
        // Settings Window (Single Instance)
        Window("Settings", id: "settings") {
            SettingsView(settingsManager: settingsManager)
        }
        .windowResizability(.contentSize)
        .defaultPosition(.center)
    }

    private func timeString(from totalSeconds: TimeInterval) -> String {
        let minutes = Int(totalSeconds) / 60
        let seconds = Int(totalSeconds) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

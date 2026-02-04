import SwiftUI
import MenuBarAppUI
import PomodoroTimerCore
import PomodoroSettings // Import PomodoroSettings

@main
struct PomodoroMenuBarAppApp: App {
    // Instantiate SettingsManager and PomodoroTimer here
    // Use @StateObject for SettingsManager if it needs to persist across app lifecycle
    // For now, @State is fine, but for production, consider @StateObject or @AppStorage for manager itself
    @State var settingsManager = SettingsManager()
    @State private var pomodoroTimer: PomodoroTimer // Declare here, initialize in init if needed
    
    init() {
        // Initialize pomodoroTimer with the settingsManager
        _pomodoroTimer = State(initialValue: PomodoroTimer(settingsManager: settingsManager))
    }

    var body: some Scene {
        MenuBarExtra {
            // Main content of the menu bar popover
            PomodoroTimerView(pomodoroTimer: pomodoroTimer)
            
            // Add a separator and a Settings button
            Divider()
            
            Button("Settings") {
                NSApp.activate(ignoringOtherApps: true) // Bring app to foreground
                // Open the settings window
                // This requires a separate WindowGroup for Settings in the App struct
                // For now, we'll just open it
                // A better approach would be to use @State and a .sheet or .window modifier
                // to control visibility.
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
        
        // Settings Window
        WindowGroup("Settings") {
            SettingsView(settingsManager: settingsManager)
        }
        .defaultPosition(.center) // Center the settings window
        .defaultSize(width: 400, height: 600) // Default size for settings window
    }

    private func timeString(from totalSeconds: TimeInterval) -> String {
        let minutes = Int(totalSeconds) / 60
        let seconds = Int(totalSeconds) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

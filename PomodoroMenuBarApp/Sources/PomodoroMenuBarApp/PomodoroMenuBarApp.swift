import SwiftUI
import MenuBarAppUI
import PomodoroTimerCore

@main
struct PomodoroMenuBarAppApp: App {
    @State private var pomodoroTimer = PomodoroTimer()

    var body: some Scene {
        MenuBarExtra {
            PomodoroTimerView(pomodoroTimer: pomodoroTimer)
        } label: {
            // Display timer remaining or a static icon
            if pomodoroTimer.state == .running || pomodoroTimer.state == .paused {
                Text(timeString(from: pomodoroTimer.timeRemaining))
            } else {
                Image(systemName: "hourglass")
            }
        }
        .menuBarExtraStyle(.window) // Makes it behave like a popover rather than a menu
    }

    private func timeString(from totalSeconds: TimeInterval) -> String {
        let minutes = Int(totalSeconds) / 60
        let seconds = Int(totalSeconds) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
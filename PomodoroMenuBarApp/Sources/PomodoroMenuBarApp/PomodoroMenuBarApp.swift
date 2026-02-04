// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import PomodoroTimerCore

@main
struct PomodoroMenuBarApp {
    static func main() {
        let pomodoroTimer = PomodoroTimer()
        print("Pomodoro Timer Initialized:")
        print("  State: \(pomodoroTimer.state.rawValue)")
        print("  Phase: \(pomodoroTimer.phase.rawValue)")
        print("  Time Remaining: \(Int(pomodoroTimer.timeRemaining)) seconds")
        
        // Example of starting the timer (for demonstration, won't run in background here)
        // pomodoroTimer.start()
        // print("Timer started. State: \(pomodoroTimer.state.rawValue)")
    }
}

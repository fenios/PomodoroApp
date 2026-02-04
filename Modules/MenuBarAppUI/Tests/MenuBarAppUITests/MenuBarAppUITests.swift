import Testing
import SwiftUI // Required for View
import PomodoroTimerCore // Required for PomodoroTimer
@testable import MenuBarAppUI

@Test func testPomodoroTimerViewInitialization() {
    // Create an instance of PomodoroTimer
    let timer = PomodoroTimer()
    
    // Attempt to create an instance of PomodoroTimerView
    // This will assert that the view can be initialized without crashing
    _ = PomodoroTimerView(pomodoroTimer: timer)
    
    // No specific assertions needed for this basic test,
    // as the goal is to ensure initialization doesn't throw.
    #expect(true, "PomodoroTimerView should initialize without crashing.")
}
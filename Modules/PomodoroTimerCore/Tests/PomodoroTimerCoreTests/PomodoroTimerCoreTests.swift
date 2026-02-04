import Testing
import Foundation
@testable import PomodoroTimerCore

@MainActor
func awaitCondition(
    _ condition: @escaping @MainActor () -> Bool,
    timeout: TimeInterval = 2.0,
    message: String = "Condition not met within timeout"
) async throws {
    let startTime = Date()
    while !condition() {
        if Date().timeIntervalSince(startTime) > timeout {
            #expect(Bool(false), Comment(rawValue: message)) // Changed to use Bool(false) and Comment(message)
            return
        }
        try await Task.sleep(nanoseconds: 10_000_000) // Sleep for 10ms
    }
}

@Test("PomodoroTimer Initial State") @MainActor func testInitialState() async throws {
    let timer = PomodoroTimer()
    #expect(timer.state == .stopped)
    #expect(timer.phase == .working)
    #expect(timer.timeRemaining == timer.configuration.pomodoroDuration)
}

@Test("PomodoroTimer Start Functionality") @MainActor func testStart() async throws {
    let timer = PomodoroTimer()
    timer.start()
    #expect(timer.state == .running)
    
    // Allow a short time for the timer to tick
    try await Task.sleep(nanoseconds: 1_100_000_000) // Sleep for 1.1 second
    #expect(timer.timeRemaining < timer.configuration.pomodoroDuration)
    #expect(timer.state == .running)
    
    timer.pause()
}

@Test("PomodoroTimer Pause Functionality") @MainActor func testPause() async throws {
    let timer = PomodoroTimer()
    timer.start()
    try await Task.sleep(nanoseconds: 1_100_000_000) // Let it run for a bit
    let timeBeforePause = timer.timeRemaining
    timer.pause()
    #expect(timer.state == .paused)
    
    // Ensure time doesn't change after pausing
    try await Task.sleep(nanoseconds: 1_100_000_000)
    #expect(timer.timeRemaining == timeBeforePause)
}

@Test("PomodoroTimer Reset Functionality") @MainActor func testReset() async throws {
    let timer = PomodoroTimer()
    timer.start()
    try await Task.sleep(nanoseconds: 1_100_000_000) // Let it run for a bit
    timer.reset()
    #expect(timer.state == .stopped)
    #expect(timer.timeRemaining == timer.configuration.pomodoroDuration)
}

@Test("PomodoroTimer Skip Functionality") @MainActor func testSkip() async throws {
    let timer = PomodoroTimer()
    timer.start()
    #expect(timer.phase == .working)
    
    timer.skip()
    #expect(timer.phase == .shortBreak)
    #expect(timer.state == .stopped)
    #expect(timer.timeRemaining == timer.configuration.shortBreakDuration)
    
    timer.skip()
    #expect(timer.phase == .working) // Alternates between work and short break in this basic implementation
    #expect(timer.state == .stopped)
    #expect(timer.timeRemaining == timer.configuration.pomodoroDuration)
}

@Test("PomodoroTimer Time Decrement") @MainActor func testTimeDecrement() async throws {
    let timer = PomodoroTimer(configuration: Configuration(pomodoroDuration: 3)) // Short duration for testing
    timer.start()
    #expect(timer.timeRemaining == 3)
    
    try await Task.sleep(nanoseconds: 1_100_000_000) // Sleep for 1.1 second
    #expect(timer.timeRemaining < 3)
    #expect(timer.timeRemaining >= 1.8 && timer.timeRemaining < 2.2) // Roughly 3 - 1.1 = 1.9
    
    try await Task.sleep(nanoseconds: 1_100_000_000) // Sleep for another 1.1 second
    #expect(timer.timeRemaining < 1.8)
    #expect(timer.timeRemaining >= 0.7 && timer.timeRemaining < 1.1) // Roughly 1.9 - 1.1 = 0.8
    
    timer.pause()
}

@Test("PomodoroTimer Phase Advancement") @MainActor func testPhaseAdvancement() async throws {
    let timer = PomodoroTimer(configuration: Configuration(pomodoroDuration: 1, shortBreakDuration: 1)) // Very short durations
    timer.start()
    #expect(timer.phase == .working)
    
    // Wait for working phase to complete and immediately check
    try await awaitCondition({ timer.state == .stopped }, timeout: 1.5, message: "Working phase did not complete in time")
    
    #expect(timer.timeRemaining == timer.configuration.shortBreakDuration) // Reset for new phase
    #expect(timer.state == .stopped) // Should stop after phase completion
    #expect(timer.phase == .shortBreak) // Should advance to short break
    
    timer.start() // Start the short break
    // Wait for short break phase to complete and immediately check
    try await awaitCondition({ timer.state == .stopped }, timeout: 1.5, message: "Short break phase did not complete in time")
    
    #expect(timer.timeRemaining == timer.configuration.pomodoroDuration) // Reset for new phase
    #expect(timer.state == .stopped)
    #expect(timer.phase == .working) // Should advance back to working
}
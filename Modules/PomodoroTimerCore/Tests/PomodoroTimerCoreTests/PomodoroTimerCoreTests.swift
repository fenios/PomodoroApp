import Testing
import Foundation
@testable import PomodoroTimerCore

@Test("PomodoroTimer Initial State") func testInitialState() async throws {
    let timer = PomodoroTimer()
    #expect(timer.state == .stopped)
    #expect(timer.phase == .working)
    #expect(timer.timeRemaining == timer.configuration.pomodoroDuration)
}

@Test("PomodoroTimer Start Functionality") func testStart() async throws {
    let timer = PomodoroTimer()
    timer.start()
    #expect(timer.state == .running)
    
    // Allow a short time for the timer to tick
    await Task.sleep(nanoseconds: 1_100_000_000) // Sleep for 1.1 second
    #expect(timer.timeRemaining < timer.configuration.pomodoroDuration)
    #expect(timer.state == .running)
    
    timer.pause()
}

@Test("PomodoroTimer Pause Functionality") func testPause() async throws {
    let timer = PomodoroTimer()
    timer.start()
    await Task.sleep(nanoseconds: 1_100_000_000) // Let it run for a bit
    let timeBeforePause = timer.timeRemaining
    timer.pause()
    #expect(timer.state == .paused)
    
    // Ensure time doesn't change after pausing
    await Task.sleep(nanoseconds: 1_100_000_000)
    #expect(timer.timeRemaining == timeBeforePause)
}

@Test("PomodoroTimer Reset Functionality") func testReset() async throws {
    let timer = PomodoroTimer()
    timer.start()
    await Task.sleep(nanoseconds: 1_100_000_000) // Let it run for a bit
    timer.reset()
    #expect(timer.state == .stopped)
    #expect(timer.timeRemaining == timer.configuration.pomodoroDuration)
}

@Test("PomodoroTimer Skip Functionality") func testSkip() async throws {
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

@Test("PomodoroTimer Time Decrement") func testTimeDecrement() async throws {
    let timer = PomodoroTimer(configuration: Configuration(pomodoroDuration: 3)) // Short duration for testing
    timer.start()
    #expect(timer.timeRemaining == 3)
    
    await Task.sleep(nanoseconds: 1_100_000_000) // Sleep for 1.1 second
    #expect(timer.timeRemaining < 3)
    #expect(timer.timeRemaining >= 1.8 && timer.timeRemaining < 2.2) // Roughly 3 - 1.1 = 1.9
    
    await Task.sleep(nanoseconds: 1_100_000_000) // Sleep for another 1.1 second
    #expect(timer.timeRemaining < 1.8)
    #expect(timer.timeRemaining >= 0.7 && timer.timeRemaining < 1.1) // Roughly 1.9 - 1.1 = 0.8
    
    timer.pause()
}

@Test("PomodoroTimer Phase Advancement") func testPhaseAdvancement() async throws {
    let timer = PomodoroTimer(configuration: Configuration(pomodoroDuration: 1, shortBreakDuration: 1)) // Very short durations
    timer.start()
    #expect(timer.phase == .working)
    
    // Wait for working phase to complete
    await Task.sleep(nanoseconds: 1_100_000_000) // 1 second + buffer
    #expect(timer.timeRemaining == 0)
    #expect(timer.state == .stopped) // Should stop after phase completion
    #expect(timer.phase == .shortBreak) // Should advance to short break
    #expect(timer.timeRemaining == timer.configuration.shortBreakDuration) // Reset for new phase
    
    timer.start() // Start the short break
    // Wait for short break phase to complete
    await Task.sleep(nanoseconds: 1_100_000_000) // 1 second + buffer
    #expect(timer.timeRemaining == 0)
    #expect(timer.state == .stopped)
    #expect(timer.phase == .working) // Should advance back to working
    #expect(timer.timeRemaining == timer.configuration.pomodoroDuration)
}
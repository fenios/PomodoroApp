import Testing
import Foundation
import PomodoroSettings // Import PomodoroSettings
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
            #expect(Bool(false), Comment(rawValue: message))
            return
        }
        try await Task.sleep(nanoseconds: 10_000_000) // Sleep for 10ms
    }
}

@Test("PomodoroTimer Initial State") @MainActor func testInitialState() async throws {
    let testSuiteName = "testInitialState"
    let userDefaults = UserDefaults(suiteName: testSuiteName)!
    userDefaults.removePersistentDomain(forName: testSuiteName)
    
    let settingsManager = SettingsManager(userDefaults: userDefaults)
    let timer = PomodoroTimer(settingsManager: settingsManager)
    #expect(timer.state == .stopped)
    #expect(timer.phase == .working)
    #expect(timer.timeRemaining == settingsManager.settings.pomodoroDuration)
    
    userDefaults.removePersistentDomain(forName: testSuiteName)
}

@Test("PomodoroTimer Start Functionality") @MainActor func testStart() async throws {
    let testSuiteName = "testStart"
    let userDefaults = UserDefaults(suiteName: testSuiteName)!
    userDefaults.removePersistentDomain(forName: testSuiteName)
    
    let settingsManager = SettingsManager(userDefaults: userDefaults)
    let timer = PomodoroTimer(settingsManager: settingsManager)
    timer.start()
    #expect(timer.state == .running)
    
    // Wait for the timer to tick at least once
    try await awaitCondition({ timer.timeRemaining < settingsManager.settings.pomodoroDuration }, timeout: 2.0, message: "Timer did not tick")
    
    #expect(timer.state == .running)
    
    timer.pause()
    userDefaults.removePersistentDomain(forName: testSuiteName)
}

@Test("PomodoroTimer Pause Functionality") @MainActor func testPause() async throws {
    let testSuiteName = "testPause"
    let userDefaults = UserDefaults(suiteName: testSuiteName)!
    userDefaults.removePersistentDomain(forName: testSuiteName)
    
    let settingsManager = SettingsManager(userDefaults: userDefaults)
    let timer = PomodoroTimer(settingsManager: settingsManager)
    timer.start()
    
    // Wait for it to run for a bit
    try await awaitCondition({ timer.timeRemaining < settingsManager.settings.pomodoroDuration }, timeout: 2.0, message: "Timer did not tick")
    
    let timeBeforePause = timer.timeRemaining
    timer.pause()
    #expect(timer.state == .paused)
    
    // Ensure time doesn't change after pausing
    try await Task.sleep(nanoseconds: 500_000_000) // 0.5s
    #expect(timer.timeRemaining == timeBeforePause)
    
    userDefaults.removePersistentDomain(forName: testSuiteName)
}

@Test("PomodoroTimer Reset Functionality") @MainActor func testReset() async throws {
    let testSuiteName = "testReset"
    let userDefaults = UserDefaults(suiteName: testSuiteName)!
    userDefaults.removePersistentDomain(forName: testSuiteName)
    
    let settingsManager = SettingsManager(userDefaults: userDefaults)
    let timer = PomodoroTimer(settingsManager: settingsManager)
    timer.start()
    
    try await awaitCondition({ timer.timeRemaining < settingsManager.settings.pomodoroDuration }, timeout: 2.0, message: "Timer did not tick")
    
    timer.reset()
    #expect(timer.state == .stopped)
    #expect(timer.timeRemaining == settingsManager.settings.pomodoroDuration)
    
    userDefaults.removePersistentDomain(forName: testSuiteName)
}

@Test("PomodoroTimer Skip Functionality") @MainActor func testSkip() async throws {
    let testSuiteName = "testSkip"
    let userDefaults = UserDefaults(suiteName: testSuiteName)!
    userDefaults.removePersistentDomain(forName: testSuiteName)
    
    let settingsManager = SettingsManager(userDefaults: userDefaults)
    let timer = PomodoroTimer(settingsManager: settingsManager)
    timer.start()
    #expect(timer.phase == .working)
    
    timer.skip()
    #expect(timer.phase == .shortBreak)
    #expect(timer.state == .stopped)
    #expect(timer.timeRemaining == settingsManager.settings.shortBreakDuration)
    
    timer.skip()
    #expect(timer.phase == .working)
    #expect(timer.state == .stopped)
    #expect(timer.timeRemaining == settingsManager.settings.pomodoroDuration)
    
    userDefaults.removePersistentDomain(forName: testSuiteName)
}

@Test("PomodoroTimer Time Decrement") @MainActor func testTimeDecrement() async throws {
    let testSuiteName = "testTimeDecrement"
    let userDefaults = UserDefaults(suiteName: testSuiteName)!
    userDefaults.removePersistentDomain(forName: testSuiteName)
    
    let settingsManager = SettingsManager(userDefaults: userDefaults)
    settingsManager.settings.pomodoroDuration = 3 // Short duration for testing
    
    let timer = PomodoroTimer(settingsManager: settingsManager)
    timer.start()
    #expect(timer.timeRemaining == 3)
    
    // Wait for the first tick
    try await awaitCondition({ timer.timeRemaining < 3.0 }, timeout: 2.0, message: "First tick did not happen")
    #expect(timer.timeRemaining <= 2.1 && timer.timeRemaining >= 1.8) // Roughly 3 - 1.0 = 2.0
    
    // Wait for the second tick
    try await awaitCondition({ timer.timeRemaining < 1.8 }, timeout: 2.0, message: "Second tick did not happen")
    #expect(timer.timeRemaining <= 1.1 && timer.timeRemaining >= 0.8) // Roughly 2.0 - 1.0 = 1.0
    
    timer.pause()
    userDefaults.removePersistentDomain(forName: testSuiteName)
}

@Test("PomodoroTimer Phase Advancement") @MainActor func testPhaseAdvancement() async throws {
    let testSuiteName = "testPhaseAdvancement"
    let userDefaults = UserDefaults(suiteName: testSuiteName)!
    userDefaults.removePersistentDomain(forName: testSuiteName)
    
    let settingsManager = SettingsManager(userDefaults: userDefaults)
    settingsManager.settings.pomodoroDuration = 1
    settingsManager.settings.shortBreakDuration = 1
    
    let timer = PomodoroTimer(settingsManager: settingsManager)
    timer.start()
    #expect(timer.phase == .working)
    
    // Wait for working phase to complete and immediately check
    try await awaitCondition({ timer.state == .stopped }, timeout: 2.5, message: "Working phase did not complete in time")
    
    #expect(timer.timeRemaining == settingsManager.settings.shortBreakDuration) // Reset for new phase
    #expect(timer.state == .stopped) // Should stop after phase completion
    #expect(timer.phase == .shortBreak) // Should advance to short break
    
    timer.start() // Start the short break
    // Wait for short break phase to complete and immediately check
    try await awaitCondition({ timer.state == .stopped }, timeout: 2.5, message: "Short break phase did not complete in time")
    
    #expect(timer.timeRemaining == settingsManager.settings.pomodoroDuration) // Reset for new phase
    #expect(timer.state == .stopped)
    #expect(timer.phase == .working) // Should advance back to working
    
    userDefaults.removePersistentDomain(forName: testSuiteName)
}
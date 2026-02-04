import Testing
import Foundation
@testable import PomodoroSettings

@Test func testDefaultSettings() {
    let settings = Settings.defaultSettings
    #expect(settings.pomodoroDuration == 25 * 60)
    #expect(settings.shortBreakDuration == 5 * 60)
    #expect(settings.longBreakDuration == 15 * 60)
    #expect(settings.autoStartBreaks == false)
    #expect(settings.autoStartPomodoros == false)
    #expect(settings.longBreakInterval == 4)
    #expect(settings.alarmSoundName == "Glass")
    #expect(settings.alarmVolume == 0.8)
    #expect(settings.alarmRepeatCount == 1)
    #expect(settings.tickingSoundName == "Purr")
    #expect(settings.tickingVolume == 0.3)
}

@Test func testSettingsCodableConformance() throws {
    let originalSettings = Settings.defaultSettings
    
    // Encode
    let encoder = JSONEncoder()
    let data = try encoder.encode(originalSettings)
    
    // Decode
    let decoder = JSONDecoder()
    let decodedSettings = try decoder.decode(Settings.self, from: data)
    
    #expect(decodedSettings == originalSettings)
}

@Test @MainActor func testSettingsManagerLoadAndSave() throws {
    // Use a temporary UserDefaults suite for testing
    let testSuiteName = "testPomodoroSettings"
    let userDefaults = UserDefaults(suiteName: testSuiteName)!
    userDefaults.removePersistentDomain(forName: testSuiteName) // Clean up before test
    
    var settingsManager = SettingsManager(userDefaults: userDefaults)
    
    // Test initial load (should be default)
    #expect(settingsManager.settings == Settings.defaultSettings)
    
    // Modify settings and save
    settingsManager.settings.pomodoroDuration = 30 * 60
    settingsManager.settings.autoStartBreaks = true
    settingsManager.settings.alarmSoundName = "Basso"
    
    // Re-initialize manager to load saved settings
    settingsManager = SettingsManager(userDefaults: userDefaults)
    
    #expect(settingsManager.settings.pomodoroDuration == 30 * 60)
    #expect(settingsManager.settings.autoStartBreaks == true)
    #expect(settingsManager.settings.alarmSoundName == "Basso")
    #expect(settingsManager.settings.shortBreakDuration == Settings.defaultSettings.shortBreakDuration) // Should remain default
    
    // Clean up
    userDefaults.removePersistentDomain(forName: testSuiteName)
}
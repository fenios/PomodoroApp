import Foundation
import AppKit // For NSSound.soundNames

public struct Settings: Codable, Hashable, Sendable {
    // MARK: - Timer Section
    public var pomodoroDuration: TimeInterval
    public var shortBreakDuration: TimeInterval
    public var longBreakDuration: TimeInterval
    public var autoStartBreaks: Bool
    public var autoStartPomodoros: Bool
    public var longBreakInterval: Int // e.g., every 4 pomodoros

    // MARK: - Sounds Section
    public var alarmSoundName: String // System sound name
    public var alarmVolume: Float
    public var alarmRepeatCount: Int // How many times the alarm sound repeats
    
    public var tickingSoundName: String // System sound name
    public var tickingVolume: Float

    public static let defaultSettings = Settings(
        pomodoroDuration: 25 * 60,
        shortBreakDuration: 5 * 60,
        longBreakDuration: 15 * 60,
        autoStartBreaks: false,
        autoStartPomodoros: false,
        longBreakInterval: 4,
        alarmSoundName: "Glass", // Default macOS system sound
        alarmVolume: 0.8,
        alarmRepeatCount: 1,
        tickingSoundName: "Purr", // Example ticking sound
        tickingVolume: 0.3
    )
    
    public init(pomodoroDuration: TimeInterval, shortBreakDuration: TimeInterval, longBreakDuration: TimeInterval, autoStartBreaks: Bool, autoStartPomodoros: Bool, longBreakInterval: Int, alarmSoundName: String, alarmVolume: Float, alarmRepeatCount: Int, tickingSoundName: String, tickingVolume: Float) {
        self.pomodoroDuration = pomodoroDuration
        self.shortBreakDuration = shortBreakDuration
        self.longBreakDuration = longBreakDuration
        self.autoStartBreaks = autoStartBreaks
        self.autoStartPomodoros = autoStartPomodoros
        self.longBreakInterval = longBreakInterval
        self.alarmSoundName = alarmSoundName
        self.alarmVolume = alarmVolume
        self.alarmRepeatCount = alarmRepeatCount
        self.tickingSoundName = tickingSoundName
        self.tickingVolume = tickingVolume
    }
}

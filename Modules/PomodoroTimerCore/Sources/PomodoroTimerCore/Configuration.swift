import Foundation

public struct Configuration {
    public var pomodoroDuration: TimeInterval
    public var shortBreakDuration: TimeInterval
    public var longBreakDuration: TimeInterval

    public init(pomodoroDuration: TimeInterval = 25 * 60,
                shortBreakDuration: TimeInterval = 5 * 60,
                longBreakDuration: TimeInterval = 15 * 60) {
        self.pomodoroDuration = pomodoroDuration
        self.shortBreakDuration = shortBreakDuration
        self.longBreakDuration = longBreakDuration
    }
}

import Foundation

public enum TimerPhase: String, Codable, CaseIterable, Identifiable, Sendable {
    public var id: String { rawValue }

    case working = "Work"
    case shortBreak = "Short Break"
    case longBreak = "Long Break"
}

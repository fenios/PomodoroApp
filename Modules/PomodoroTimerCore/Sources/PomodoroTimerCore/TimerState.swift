import Foundation

public enum TimerState: String, Codable, CaseIterable, Identifiable, Sendable {
    public var id: String { rawValue }

    case stopped
    case running
    case paused
}

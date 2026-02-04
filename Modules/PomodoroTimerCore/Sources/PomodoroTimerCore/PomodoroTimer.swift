import Foundation
import Observation

@Observable
public final class PomodoroTimer {
    public var state: TimerState = .stopped
    public var phase: TimerPhase = .working
    public var timeRemaining: TimeInterval
    public var configuration: Configuration

    private var timerTask: Task<Void, Never>?
    private var lastTick: Date?

    public init(configuration: Configuration = Configuration()) {
        self.configuration = configuration
        self.timeRemaining = configuration.pomodoroDuration
    }

    public func start() {
        guard state != .running else { return }

        if state == .stopped {
            resetTimeForCurrentPhase()
        }

        state = .running
        lastTick = Date()

        timerTask = Task { [weak self] in
            while let self = self, self.state == .running {
                await Task.sleep(nanoseconds: 1_000_000_000) // Sleep for 1 second
                await MainActor.run {
                    self.tick()
                }
            }
            if self?.state != .running {
                self?.timerTask?.cancel()
                self?.timerTask = nil
            }
        }
    }

    public func pause() {
        guard state == .running else { return }
        state = .paused
        timerTask?.cancel()
        timerTask = nil
    }

    public func reset() {
        timerTask?.cancel()
        timerTask = nil
        state = .stopped
        resetTimeForCurrentPhase()
    }

    public func skip() {
        timerTask?.cancel()
        timerTask = nil
        advancePhase()
        state = .stopped
        resetTimeForCurrentPhase()
    }

    private func tick() {
        guard state == .running, let lastTick = lastTick else { return }
        let now = Date()
        let elapsed = now.timeIntervalSince(lastTick)
        self.lastTick = now

        timeRemaining -= elapsed

        if timeRemaining <= 0 {
            timeRemaining = 0
            advancePhase()
            state = .stopped
            timerTask?.cancel()
            timerTask = nil
            resetTimeForCurrentPhase()
        }
    }

    private func advancePhase() {
        switch phase {
        case .working:
            phase = .shortBreak
        case .shortBreak:
            phase = .working // For simplicity, alternate between work and short break
        case .longBreak:
            phase = .working
        }
    }

    private func resetTimeForCurrentPhase() {
        switch phase {
        case .working:
            timeRemaining = configuration.pomodoroDuration
        case .shortBreak:
            timeRemaining = configuration.shortBreakDuration
        case .longBreak:
            timeRemaining = configuration.longBreakDuration
        }
    }
}

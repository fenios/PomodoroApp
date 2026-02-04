import Foundation
import Observation
import AppKit // Import AppKit for NSSound
import PomodoroSettings // Import PomodoroSettings

@MainActor
@Observable
public final class PomodoroTimer {
    public var state: TimerState = .stopped
    public var phase: TimerPhase = .working
    public var timeRemaining: TimeInterval
    private var pomodoroCount: Int = 0 // Track completed pomodoros for long break

    @ObservationIgnored private let settingsManager: SettingsManager
    @ObservationIgnored private var tickingSound: NSSound?

    private var timerTask: Task<Void, Never>?
    private var lastTick: Date?

    public init(settingsManager: SettingsManager = SettingsManager()) {
        self.settingsManager = settingsManager
        self.timeRemaining = settingsManager.settings.pomodoroDuration
        
        // Setup ticking sound when settings change or initially
        withObservationTracking {
            _ = settingsManager.settings.tickingSoundName
            _ = settingsManager.settings.tickingVolume
        } onChange: {
            Task { @MainActor [weak self] in
                self?.setupTickingSound()
            }
        }
        setupTickingSound() // Initial setup
    }

    public func start() {
        guard state != .running else { return }

        if state == .stopped {
            resetTimeForCurrentPhase()
        }

        state = .running
        lastTick = Date()
        playTickingSound() // Start ticking sound when timer starts

        timerTask = Task { [weak self] in
            while let self = self, self.state == .running {
                do {
                    try await Task.sleep(nanoseconds: 1_000_000_000) // Sleep for 1 second
                } catch {
                    // Task was cancelled, break the loop
                    break
                }
                await MainActor.run {
                    self.tick()
                }
            }
            if self?.state != .running {
                self?.stopTickingSound() // Stop ticking sound if timer stops
                // If timer stopped naturally (not paused/reset externally) and auto-start is on
                if self?.state == .stopped { // Double check state after loop ends
                    if self?.settingsManager.settings.autoStartBreaks == true && self?.phase == .working {
                        self?.advancePhase() // Advance to break
                        self?.start() // Auto-start break
                    } else if self?.settingsManager.settings.autoStartPomodoros == true && (self?.phase == .shortBreak || self?.phase == .longBreak) {
                        self?.advancePhase() // Advance to working
                        self?.start() // Auto-start pomodoro
                    }
                }
                self?.timerTask?.cancel()
                self?.timerTask = nil
            }
        }
    }

    public func pause() {
        guard state == .running else { return }
        state = .paused
        stopTickingSound() // Stop ticking sound when paused
        timerTask?.cancel()
        timerTask = nil
    }

    public func reset() {
        timerTask?.cancel()
        timerTask = nil
        state = .stopped
        stopTickingSound() // Stop ticking sound when reset
        // Reset pomodoro count only if resetting from working phase
        if phase == .working {
            pomodoroCount = 0
        }
        resetTimeForCurrentPhase()
    }

    public func skip() {
        timerTask?.cancel()
        timerTask = nil
        stopTickingSound() // Stop ticking sound when skipped
        
        // Handle pomodoro count only if skipping a working phase
        if phase == .working {
            pomodoroCount += 1
        }
        
        advancePhase()
        state = .stopped
        resetTimeForCurrentPhase()
        
        // Auto-start next phase if enabled
        if settingsManager.settings.autoStartBreaks && (phase == .shortBreak || phase == .longBreak) {
            start()
        } else if settingsManager.settings.autoStartPomodoros && phase == .working {
            start()
        }
    }

    private func tick() {
        guard state == .running, let lastTick = lastTick else { return }
        let now = Date()
        let elapsed = now.timeIntervalSince(lastTick)
        self.lastTick = now

        timeRemaining -= elapsed

        if timeRemaining <= 0 {
            timeRemaining = 0
            
            // Play alarm sound
            playAlarmSound()
            stopTickingSound() // Stop ticking sound when cycle ends

            // Increment pomodoro count if a working phase just finished
            if phase == .working {
                pomodoroCount += 1
            }
            
            state = .stopped // Set state to stopped immediately
            timerTask?.cancel() // Cancel current task
            timerTask = nil // Clear task

            // Logic to advance phase and reset time is now handled in `start()` if auto-start is on
            // or explicitly after `skip()` or next `start()` call.
            // For now, if not auto-starting, just advance phase and reset time
            if !(settingsManager.settings.autoStartBreaks && phase == .working) &&
               !(settingsManager.settings.autoStartPomodoros && (phase == .shortBreak || phase == .longBreak)) {
                
                advancePhase() // This will update 'phase'
                resetTimeForCurrentPhase() // This will update 'timeRemaining' based on the new 'phase'
            }
        }
    }
    
    private func setupTickingSound() {
        if settingsManager.settings.tickingSoundName.isEmpty {
            tickingSound = nil
            return
        }
        tickingSound = NSSound(named: NSSound.Name(settingsManager.settings.tickingSoundName))
        tickingSound?.volume = settingsManager.settings.tickingVolume
        tickingSound?.loops = true // Ticking sound always loops
        // Ensure sound is stopped before new setup to prevent multiple instances playing
        tickingSound?.stop()
    }
    
    private func playTickingSound() {
        // Only play if not already playing and timer is running
        if state == .running && tickingSound?.isPlaying == false {
            tickingSound?.play()
        }
    }
    
    private func stopTickingSound() {
        tickingSound?.stop()
    }
    
    private func playAlarmSound() {
        let alarmSoundName = settingsManager.settings.alarmSoundName
        let alarmVolume = settingsManager.settings.alarmVolume
        let alarmRepeatCount = settingsManager.settings.alarmRepeatCount

        if let sound = NSSound(named: NSSound.Name(alarmSoundName)) {
            sound.volume = alarmVolume
            // NSSound.loops works for multiple plays, for single play, it's false
            sound.loops = (alarmRepeatCount > 1)
            sound.play()
            // If loops is false but repeatCount is 1, it plays once.
            // If loops is true, it plays indefinitely until stop().
            // If repeatCount is 0, it means no sound.
            // For alarmRepeatCount == 1, loops is false, plays once.
            // For alarmRepeatCount > 1, loops is true, will play until manually stopped.
            // This is still not perfect for exact 'repeatCount' (e.g., play 3 times and stop).
            // A proper implementation would involve NSSoundDelegate or scheduling each play with a delay.
            // For now, if >1, it loops indefinitely. If 0, it shouldn't play at all.
            if alarmRepeatCount == 0 {
                sound.stop() // Ensure it doesn't play if repeat count is 0
            }
        }
    }

    private func advancePhase() {
        switch phase {
        case .working:
            // Check for long break
            if pomodoroCount % settingsManager.settings.longBreakInterval == 0 {
                phase = .longBreak
            } else {
                phase = .shortBreak
            }
        case .shortBreak, .longBreak:
            phase = .working
        }
        // timeRemaining will be reset by resetTimeForCurrentPhase()
    }

    private func resetTimeForCurrentPhase() {
        switch phase {
        case .working:
            timeRemaining = settingsManager.settings.pomodoroDuration
        case .shortBreak:
            timeRemaining = settingsManager.settings.shortBreakDuration
        case .longBreak:
            timeRemaining = settingsManager.settings.longBreakDuration
        }
    }
}

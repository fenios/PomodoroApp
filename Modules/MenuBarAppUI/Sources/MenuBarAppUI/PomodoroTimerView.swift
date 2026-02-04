import SwiftUI
import PomodoroTimerCore

public struct PomodoroTimerView: View {
    @Bindable var pomodoroTimer: PomodoroTimer

    public init(pomodoroTimer: PomodoroTimer) {
        self.pomodoroTimer = pomodoroTimer
    }

    public var body: some View {
        VStack(spacing: 15) {
            Text(pomodoroTimer.phase.rawValue)
                .font(.headline)
                .padding(.bottom, 5)

            Text(timeString(from: pomodoroTimer.timeRemaining))
                .font(.largeTitle)
                .monospacedDigit()
                .padding(.vertical, 5)
            
            HStack(spacing: 15) {
                Button(action: {
                    if pomodoroTimer.state == .running {
                        pomodoroTimer.pause()
                    } else {
                        pomodoroTimer.start()
                    }
                }) {
                    Image(systemName: pomodoroTimer.state == .running ? "pause.fill" : "play.fill")
                        .font(.title2)
                }
                .buttonStyle(.plain)

                Button(action: {
                    pomodoroTimer.reset()
                }) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.title2)
                }
                .buttonStyle(.plain)

                Button(action: {
                    pomodoroTimer.skip()
                }) {
                    Image(systemName: "forward.end.fill")
                        .font(.title2)
                }
                .buttonStyle(.plain)
            }
            .padding(.top, 5)
        }
        .padding()
        .frame(minWidth: 200, minHeight: 150)
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in
            // Optional: Handle app becoming active, e.g., resume timer if paused
            // Or use this to ensure UI updates when app comes to foreground
        }
    }

    private func timeString(from totalSeconds: TimeInterval) -> String {
        let minutes = Int(totalSeconds) / 60
        let seconds = Int(totalSeconds) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

// Preview Provider (for Xcode canvas)
#Preview {
    PomodoroTimerView(pomodoroTimer: PomodoroTimer())
}

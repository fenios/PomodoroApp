# PomodoroTimerCore

`PomodoroTimerCore` is a Swift Package module that encapsulates the core logic for a Pomodoro timer. It is built using Swift's new Observation framework (`@Observable`) and structured concurrency (`async/await`, `Task`).

## Features

-   **Timer Management:** Start, pause, reset, and skip timer phases.
-   **State Tracking:** Clearly defined states (`stopped`, `running`, `paused`) and phases (`working`, `shortBreak`, `longBreak`).
-   **Configurable Durations:** Easy configuration of Pomodoro, short break, and long break durations.
-   **Observable State:** The `PomodoroTimer` class is `@Observable`, making it easy to integrate with SwiftUI views for real-time updates.

## Usage

### Initialization

You can initialize `PomodoroTimer` with default durations or provide a custom `Configuration`:

```swift
import PomodoroTimerCore

// Default configuration
let timer = PomodoroTimer()

// Custom configuration (e.g., for testing or user preferences)
let customConfig = Configuration(pomodoroDuration: 10 * 60, shortBreakDuration: 2 * 60, longBreakDuration: 5 * 60)
let customTimer = PomodoroTimer(configuration: customConfig)
```

### Controlling the Timer

```swift
// Start the timer
timer.start()

// Pause the timer
timer.pause()

// Reset the timer to the beginning of the current phase
timer.reset()

// Skip to the next phase
timer.skip()
```

### Observing State Changes

Since `PomodoroTimer` is `@Observable`, you can easily observe its properties in a SwiftUI View:

```swift
import SwiftUI
import PomodoroTimerCore

struct TimerView: View {
    @State private var pomodoroTimer = PomodoroTimer()

    var body: some View {
        VStack {
            Text("Phase: \(pomodoroTimer.phase.rawValue)")
            Text("Time Remaining: \(Int(pomodoroTimer.timeRemaining))s")

            HStack {
                Button("Start") {
                    pomodoroTimer.start()
                }
                Button("Pause") {
                    pomodoroTimer.pause()
                }
                Button("Reset") {
                    pomodoroTimer.reset()
                }
                Button("Skip") {
                    pomodoroTimer.skip()
                }
            }
        }
    }
}
```

## Structure

-   `PomodoroTimer.swift`: The main `@Observable` class managing timer logic and state.
-   `TimerState.swift`: Defines the `TimerState` enum (`stopped`, `running`, `paused`).
-   `TimerPhase.swift`: Defines the `TimerPhase` enum (`working`, `shortBreak`, `longBreak`).
-   `Configuration.swift`: Defines the `Configuration` struct for timer durations.

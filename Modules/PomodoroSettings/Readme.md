# PomodoroSettings

`PomodoroSettings` is a Swift Package module dedicated to managing user-configurable settings for the Pomodoro application. It provides a `Codable` `Settings` model, an `Observable` `SettingsManager` for persistence via `UserDefaults`, and a SwiftUI `SettingsView` for user interaction.

## Features

-   **`Settings` Model**: A `Codable` struct that defines all configurable parameters for the Pomodoro timer, including durations, auto-start options, long break intervals, and sound preferences.
-   **`SettingsManager`**: An `@Observable` class responsible for loading default or saved `Settings` from `UserDefaults` and persisting changes. It acts as the single source of truth for application settings.
-   **`SettingsView`**: A SwiftUI `View` that provides a user interface for editing all parameters defined in the `Settings` model. It features custom controls for time intervals, toggles, steppers, and system sound pickers with volume control.
-   **Integration with `PomodoroTimerCore`**: `PomodoroTimer` (from `PomodoroTimerCore`) is designed to depend on `SettingsManager` to dynamically adjust its behavior based on user preferences.

## Usage

### `Settings` Model

The `Settings` struct defines the various parameters:

```swift
public struct Settings: Codable, Hashable {
    // Timer Section
    public var pomodoroDuration: TimeInterval
    public var shortBreakDuration: TimeInterval
    public var longBreakDuration: TimeInterval
    public var autoStartBreaks: Bool
    public var autoStartPomodoros: Bool
    public var longBreakInterval: Int

    // Sounds Section
    public var alarmSoundName: String
    public var alarmVolume: Float
    public var alarmRepeatCount: Int
    public var tickingSoundName: String
    public var tickingVolume: Float

    public static let defaultSettings: Settings
    // ... init and other details
}
```

### `SettingsManager`

Instantiate and use `SettingsManager` to access and modify settings. Changes are automatically saved to `UserDefaults`.

```swift
import PomodoroSettings
import Observation

@MainActor // SettingsManager is often accessed on the main actor
public final class SettingsManager {
    public var settings: Settings { /* ... */ }
    public init(userDefaults: UserDefaults = .standard) { /* ... */ }
}
```

### `SettingsView`

The `SettingsView` is a SwiftUI interface. It takes an `@Bindable SettingsManager` instance:

```swift
import SwiftUI
import AppKit

public struct SettingsView: View {
    @Bindable var settingsManager: SettingsManager

    public init(settingsManager: SettingsManager) { /* ... */ }

    public var body: some View { /* ... */ }
}
```

### Integration in main App (e.g., `PomodoroMenuBarApp`)

```swift
import SwiftUI
import PomodoroSettings
import PomodoroTimerCore

@main
struct PomodoroMenuBarAppApp: App {
    @State var settingsManager = SettingsManager()
    @State private var pomodoroTimer: PomodoroTimer
    
    init() {
        _pomodoroTimer = State(initialValue: PomodoroTimer(settingsManager: settingsManager))
    }

    var body: some Scene {
        MenuBarExtra {
            // ... PomodoroTimerView ...
            Button("Settings") {
                // Logic to show settings window/sheet
            }
        } label: { /* ... */ }
        
        WindowGroup("Settings") {
            SettingsView(settingsManager: settingsManager)
        }
    }
}
```
## Structure
- `Settings.swift`: Defines the `Settings` Codable struct for all configurable parameters.
- `SettingsManager.swift`: Manages loading and saving `Settings` to `UserDefaults`.
- `SettingsView.swift`: Provides the SwiftUI user interface for modifying settings.
- `PomodoroSettings.swift`: (Initially generated, can be left empty or removed if not needed for module-specific public utilities).

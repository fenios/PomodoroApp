# MenuBarAppUI

`MenuBarAppUI` is a Swift Package module responsible for the user interface components of the Pomodoro menu bar application. It integrates the core timer logic from `PomodoroTimerCore` and presents it in a compact, interactive SwiftUI view designed for an `NSPopover`.

## Features

-   **`PomodoroTimerView`**: A SwiftUI view that displays the current Pomodoro phase, remaining time, and provides controls (start/pause, reset, skip) for the `PomodoroTimer`.
-   **Integration with `PomodoroTimerCore`**: Seamlessly observes and interacts with the `PomodoroTimer` instance for real-time updates and control.
-   **Pop-over ready**: Designed to be hosted within an `NSPopover` from a macOS `NSStatusItem`.

## Usage

The `PomodoroTimerView` is designed to be instantiated within an `NSHostingController` and presented via an `NSPopover`. It requires an instance of `PomodoroTimer` to be passed to its initializer.

### Example Integration (within an `NSApplicationDelegate`):

```swift
import SwiftUI
import AppKit
import MenuBarAppUI
import PomodoroTimerCore

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var popover: NSPopover!
    var pomodoroTimer = PomodoroTimer() // Owned by the AppDelegate

    func applicationDidFinishLaunching(_ notification: Notification) {
        // ... (status item setup) ...

        popover = NSPopover()
        popover.contentSize = NSSize(width: 250, height: 200)
        popover.behavior = .transient
        // Pass the owned PomodoroTimer instance to the SwiftUI view
        popover.contentViewController = NSHostingController(rootView: PomodoroTimerView(pomodoroTimer: pomodoroTimer))
        
        // ... (application policy setup) ...
    }

    @objc func togglePopover(_ sender: Any?) {
        if popover.isShown {
            popover.performClose(sender)
        } else {
            // Logic to start timer if stopped, then show popover
            if pomodoroTimer.state == .stopped {
                pomodoroTimer.start()
            }
            if let button = statusItem.button {
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            }
        }
    }
}
```

## Structure

-   `PomodoroTimerView.swift`: The main SwiftUI view for displaying and controlling the timer.
-   `MenuBarAppUI.swift`: (Initially generated, can be left empty or removed if not needed for module-specific public utilities).

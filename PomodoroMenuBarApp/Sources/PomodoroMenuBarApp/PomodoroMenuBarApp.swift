import SwiftUI
import AppKit
import MenuBarAppUI
import PomodoroTimerCore // Also import PomodoroTimerCore for state management

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var popover: NSPopover!
    var pomodoroTimer: PomodoroTimer // Keep an instance of the timer

    override init() {
        self.pomodoroTimer = PomodoroTimer() // Initialize the timer
        super.init()
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Create the status item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "hourglass", accessibilityDescription: "Pomodoro Timer")
            button.action = #selector(togglePopover(_:))
        }

        // Create the popover
        popover = NSPopover()
        popover.contentSize = NSSize(width: 250, height: 200) // Adjust size as needed
        popover.behavior = .transient // Dismisses when clicking outside
        popover.contentViewController = NSHostingController(rootView: PomodoroTimerView(pomodoroTimer: pomodoroTimer))
        
        // Hide the app from the Dock and Cmd+Tab switcher
        NSApp.setActivationPolicy(.accessory)
    }

    @objc func togglePopover(_ sender: Any?) {
        if popover.isShown {
            popover.performClose(sender)
        } else {
            // If the timer is stopped, start it when the popover is opened
            if pomodoroTimer.state == .stopped {
                pomodoroTimer.start()
            }
            if let button = statusItem.button {
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            }
        }
    }
}

// This is the entry point for a SwiftUI App with an AppDelegate
// The actual @main for the app itself is the AppDelegate
@main
struct AppEntry {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    static func main() {
        // This is where the NSApplication starts
        // We defer control to the AppDelegate for setup
        NSApplication.shared.run()
    }
}
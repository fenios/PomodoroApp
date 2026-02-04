import SwiftUI
import AppKit
import Observation

public struct SettingsView: View {
    @Bindable var settingsManager: SettingsManager

    public init(settingsManager: SettingsManager) {
        self.settingsManager = settingsManager
    }

    private let systemSounds = ["Basso", "Blow", "Bottle", "Frog", "Funk", "Glass", "Hero", "Morse", "Ping", "Pop", "Purr", "Sosumi", "Submarine", "Tink"]

    public var body: some View {
        Form {
            // MARK: - Timer Section
            Section("Timer") {
                TimeIntervalPicker(label: "Pomodoro Duration", selection: $settingsManager.settings.pomodoroDuration)
                TimeIntervalPicker(label: "Short Break Duration", selection: $settingsManager.settings.shortBreakDuration)
                TimeIntervalPicker(label: "Long Break Duration", selection: $settingsManager.settings.longBreakDuration)
                
                Toggle("Auto Start Breaks", isOn: $settingsManager.settings.autoStartBreaks)
                Toggle("Auto Start Pomodoros", isOn: $settingsManager.settings.autoStartPomodoros)
                
                Stepper("Long Break Interval: \(settingsManager.settings.longBreakInterval)", value: $settingsManager.settings.longBreakInterval, in: 1...10)
            }
            
            // MARK: - Sounds Section
            Section("Sounds") {
                VStack(alignment: .leading) {
                    Text("Alarm Sound")
                    Picker("Alarm Sound", selection: $settingsManager.settings.alarmSoundName) {
                        ForEach(systemSounds, id: \.self) { soundName in
                            Text(soundName)
                                .tag(soundName)
                        }
                    }
                    .onChange(of: settingsManager.settings.alarmSoundName) { oldValue, newValue in
                        // Play sound when selected
                        if let sound = NSSound(named: NSSound.Name(newValue)) {
                            sound.volume = settingsManager.settings.alarmVolume
                            sound.play()
                        }
                    }
                    
                    Slider(value: $settingsManager.settings.alarmVolume, in: 0...1, step: 0.05) {
                        Text("Volume")
                    } minimumValueLabel: {
                        Image(systemName: "speaker.fill")
                    } maximumValueLabel: {
                        Image(systemName: "speaker.wave.3.fill")
                    }
                    .padding(.horizontal)
                    
                    Stepper("Repeat: \(settingsManager.settings.alarmRepeatCount)", value: $settingsManager.settings.alarmRepeatCount, in: 0...5)
                }
                
                VStack(alignment: .leading) {
                    Text("Ticking Sound")
                    Picker("Ticking Sound", selection: $settingsManager.settings.tickingSoundName) {
                        ForEach(systemSounds, id: \.self) { soundName in
                            Text(soundName)
                                .tag(soundName)
                        }
                    }
                    .onChange(of: settingsManager.settings.tickingSoundName) { oldValue, newValue in
                        // Play sound when selected
                        if let sound = NSSound(named: NSSound.Name(newValue)) {
                            sound.volume = settingsManager.settings.tickingVolume
                            sound.play()
                        }
                    }
                    
                    Slider(value: $settingsManager.settings.tickingVolume, in: 0...1, step: 0.05) {
                        Text("Volume")
                    } minimumValueLabel: {
                        Image(systemName: "speaker.fill")
                    } maximumValueLabel: {
                        Image(systemName: "speaker.wave.3.fill")
                    }
                    .padding(.horizontal)
                }
            }
        }
        .padding()
        .frame(width: 400) // Fixed width for settings window
    }
}

// Helper view for TimeInterval selection
struct TimeIntervalPicker: View {
    let label: String
    @Binding var selection: TimeInterval
    
    // Convert TimeInterval (seconds) to minutes for display and editing
    @State private var minutes: Int
    
    init(label: String, selection: Binding<TimeInterval>) {
        self.label = label
        self._selection = selection
        self._minutes = State(initialValue: Int(selection.wrappedValue / 60))
    }
    
    var body: some View {
        Stepper("\(label): \(minutes) min", value: $minutes, in: 1...60)
            .onChange(of: minutes) { oldValue, newValue in
                selection = TimeInterval(newValue * 60)
            }
    }
}

// Preview Provider
#Preview {
    // Create a dummy SettingsManager for preview
    let manager = SettingsManager()
    return SettingsView(settingsManager: manager)
        .padding()
}

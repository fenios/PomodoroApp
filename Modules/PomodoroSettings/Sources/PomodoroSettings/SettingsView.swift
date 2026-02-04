import SwiftUI
import AppKit
import Observation

public struct SettingsView: View {
    @Bindable var settingsManager: SettingsManager
    @State private var draftSettings: Settings
    
    @Environment(\.dismiss) private var dismiss

    public init(settingsManager: SettingsManager) {
        self.settingsManager = settingsManager
        // Initialize draft with current settings
        self._draftSettings = State(initialValue: settingsManager.settings)
    }

    private let systemSounds = ["Basso", "Blow", "Bottle", "Frog", "Funk", "Glass", "Hero", "Morse", "Ping", "Pop", "Purr", "Sosumi", "Submarine", "Tink"]

    public var body: some View {
        VStack(spacing: 0) {
            Form {
                // MARK: - Timer Section
                Section("Timer") {
                    TimeIntervalPicker(label: "Pomodoro Duration", selection: $draftSettings.pomodoroDuration)
                    TimeIntervalPicker(label: "Short Break Duration", selection: $draftSettings.shortBreakDuration)
                    TimeIntervalPicker(label: "Long Break Duration", selection: $draftSettings.longBreakDuration)
                    
                    Toggle("Auto Start Breaks", isOn: $draftSettings.autoStartBreaks)
                    Toggle("Auto Start Pomodoros", isOn: $draftSettings.autoStartPomodoros)
                    
                    Stepper("Long Break Interval: \(draftSettings.longBreakInterval)", value: $draftSettings.longBreakInterval, in: 1...10)
                }
                
                // MARK: - Sounds Section
                Section("Sounds") {
                    VStack(alignment: .leading) {
                        Text("Alarm Sound")
                        Picker("Alarm Sound", selection: $draftSettings.alarmSoundName) {
                            ForEach(systemSounds, id: \.self) { soundName in
                                Text(soundName)
                                    .tag(soundName)
                            }
                        }
                        .onChange(of: draftSettings.alarmSoundName) { oldValue, newValue in
                            // Preview sound when selected
                            previewSound(named: newValue, volume: draftSettings.alarmVolume)
                        }
                        
                        Slider(value: $draftSettings.alarmVolume, in: 0...1, step: 0.05) {
                            Text("Volume")
                        } minimumValueLabel: {
                            Image(systemName: "speaker.fill")
                        } maximumValueLabel: {
                            Image(systemName: "speaker.wave.3.fill")
                        }
                        .padding(.horizontal)
                        
                        Stepper("Repeat: \(draftSettings.alarmRepeatCount)", value: $draftSettings.alarmRepeatCount, in: 0...5)
                    }
                    
                    Divider()
                    
                    VStack(alignment: .leading) {
                        Text("Ticking Sound")
                        Picker("Ticking Sound", selection: $draftSettings.tickingSoundName) {
                            ForEach(systemSounds, id: \.self) { soundName in
                                Text(soundName)
                                    .tag(soundName)
                            }
                        }
                        .onChange(of: draftSettings.tickingSoundName) { oldValue, newValue in
                            // Preview sound when selected
                            previewSound(named: newValue, volume: draftSettings.tickingVolume)
                        }
                        
                        Slider(value: $draftSettings.tickingVolume, in: 0...1, step: 0.05) {
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
            .formStyle(.grouped)
            
            Divider()
            
            // Action Buttons
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                .keyboardShortcut(.escape, modifiers: [])
                
                Spacer()
                
                Button("Apply") {
                    applyChanges()
                }
                .buttonStyle(.borderedProminent)
                .keyboardShortcut(.return, modifiers: [])
            }
            .padding()
            .background(.thinMaterial)
        }
        .frame(width: 450, height: 550)
    }
    
    private func previewSound(named name: String, volume: Float) {
        if let sound = NSSound(named: NSSound.Name(name)) {
            sound.volume = volume
            sound.play()
        }
    }
    
    private func applyChanges() {
        // Commit draft to manager
        settingsManager.settings = draftSettings
        dismiss()
    }
}

// Helper view for TimeInterval selection
struct TimeIntervalPicker: View {
    let label: String
    @Binding var selection: TimeInterval
    
    // Use a computed property to interface between the Binding and the Stepper
    private var minutes: Binding<Int> {
        Binding(
            get: { Int(selection / 60) },
            set: { selection = TimeInterval($0 * 60) }
        )
    }
    
    var body: some View {
        Stepper("\(label): \(minutes.wrappedValue) min", value: minutes, in: 1...60)
    }
}

// Preview Provider
#Preview {
    let manager = SettingsManager()
    return SettingsView(settingsManager: manager)
}
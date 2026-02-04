import Foundation
import Observation

@Observable
public final class SettingsManager {
    public var settings: Settings {
        didSet {
            saveSettings()
        }
    }
    
    private let userDefaults: UserDefaults
    private let settingsKey = "pomodoroAppSettings"

    public init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        self.settings = SettingsManager.loadSettings(from: userDefaults, key: settingsKey)
    }

    private static func loadSettings(from userDefaults: UserDefaults, key: String) -> Settings {
        if let data = userDefaults.data(forKey: key) {
            if let decodedSettings = try? JSONDecoder().decode(Settings.self, from: data) {
                return decodedSettings
            }
        }
        return .defaultSettings
    }

    private func saveSettings() {
        if let encoded = try? JSONEncoder().encode(settings) {
            userDefaults.set(encoded, forKey: settingsKey)
        }
    }
}

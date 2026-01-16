import Foundation
import AlarmKit

class AppAlarmManager {
    static let shared = AppAlarmManager()
    
    private let alarmsKey = "savedAlarms"
    private let systemAlarmManager = AlarmKit.AlarmManager.shared
    
    private init() {}
    
    // MARK: - AlarmKit Authorization
    var authorizationState: AlarmKit.AlarmManager.AuthorizationState {
        return systemAlarmManager.authorizationState
    }
    
    func requestAuthorization() async throws -> AlarmKit.AlarmManager.AuthorizationState {
        return try await systemAlarmManager.requestAuthorization()
    }
    
    // MARK: - AlarmKit Updates Stream
    var alarmUpdates: some AsyncSequence<[AlarmKit.Alarm], Never> {
        return systemAlarmManager.alarmUpdates
    }
    
    // MARK: - Alarm Storage (Local)
    func saveAlarms(_ alarms: [Alarm]) {
        if let encoded = try? JSONEncoder().encode(alarms) {
            UserDefaults.standard.set(encoded, forKey: alarmsKey)
        }
    }
    
    func loadAlarms() -> [Alarm] {
        guard let data = UserDefaults.standard.data(forKey: alarmsKey),
              let alarms = try? JSONDecoder().decode([Alarm].self, from: data) else {
            return []
        }
        return alarms
    }
    
    // MARK: - Schedule Alarm with AlarmKit
    // Специализируем под наш Metadata
    func schedule(id: UUID, configuration: AlarmKit.AlarmManager.AlarmConfiguration<AlarmMetadata>) async throws -> AlarmKit.Alarm {
        return try await systemAlarmManager.schedule(id: id, configuration: configuration)
    }

    func cancel(id: UUID) throws {
        try systemAlarmManager.cancel(id: id)
    }
    
    // MARK: - Get Scheduled Alarms from System
    func getSystemAlarms() async -> [AlarmKit.Alarm] {
        do {
            return try systemAlarmManager.alarms
        } catch {
            print("Error fetching system alarms: \(error)")
            return []
        }
    }
}

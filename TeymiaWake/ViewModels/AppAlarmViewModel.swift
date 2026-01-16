import ActivityKit
import AppIntents
import Foundation
import SwiftUI
import AlarmKit

@Observable
class AppAlarmViewModel {
    private let appAlarmManager = AppAlarmManager.shared
    var alarms: [AppAlarm] = []
    var showingAddAlarm = false
    var isAuthorized = false
    
    init() {
        loadAlarms()
        observeAlarmUpdates()
    }
    
    var authorizationState: AlarmKit.AlarmManager.AuthorizationState {
        appAlarmManager.authorizationState
        }
    
    // MARK: - Authorization
    func requestAuthorization() async {
        let currentState = appAlarmManager.authorizationState
        
        switch currentState {
        case .notDetermined:
            do {
                let state = try await appAlarmManager.requestAuthorization()
                await MainActor.run {
                    isAuthorized = (state == .authorized)
                }
                print("AlarmKit authorization: \(state)")
            } catch {
                print("Error requesting authorization: \(error)")
            }
        case .authorized:
            await MainActor.run {
                isAuthorized = true
            }
            print("AlarmKit already authorized")
        case .denied:
            await MainActor.run {
                isAuthorized = false
            }
            print("AlarmKit authorization denied")
        @unknown default:
            break
        }
    }
    
    // MARK: - Load Alarms
    func loadAlarms() {
        if let data = UserDefaults.standard.data(forKey: "savedAlarms"),
           let decoded = try? JSONDecoder().decode([AppAlarm].self, from: data) {
            alarms = decoded
        }
    }
    
    // MARK: - Save Alarms
    func saveAlarms() {
        if let encoded = try? JSONEncoder().encode(alarms) {
            UserDefaults.standard.set(encoded, forKey: "savedAlarms")
        }
    }
    
    // MARK: - Add Alarm
    func addAlarm(_ alarm: AppAlarm) {
        alarms.append(alarm)
        saveAlarms()
        scheduleAlarm(alarm)
    }
    
    // MARK: - Update Alarm
    func updateAlarm(_ alarm: AppAlarm) {
        if let index = alarms.firstIndex(where: { $0.id == alarm.id }) {
            alarms[index] = alarm
            saveAlarms()
            scheduleAlarm(alarm)
        }
    }
    
    // MARK: - Delete Alarm
    func deleteAlarm(_ alarm: AppAlarm) {
        alarms.removeAll { $0.id == alarm.id }
        saveAlarms()
        cancelAlarm(alarm)
    }
    
    // MARK: - Toggle Alarm
    func toggleAlarm(_ alarm: AppAlarm) {
        if let index = alarms.firstIndex(where: { $0.id == alarm.id }) {
            alarms[index].isEnabled.toggle()
            saveAlarms()
            
            if alarms[index].isEnabled {
                scheduleAlarm(alarms[index])
            } else {
                cancelAlarm(alarms[index])
            }
        }
    }
    
    // MARK: - AlarmKit Scheduling
    private func scheduleAlarm(_ alarm: AppAlarm) {
        guard isAuthorized, alarm.isEnabled else { return }
        
        Task {
            do {
                // Stop button
                let stopButton = AlarmButton(
                    text: LocalizedStringResource(stringLiteral: "Stop"),
                    textColor: .red,
                    systemImageName: "stop.fill"
                )
                
                // Alert presentation
                let alertPresentation: AlarmPresentation.Alert
                if alarm.missionType != .none {
                    let missionButton = AlarmButton(
                        text: LocalizedStringResource(stringLiteral: "Complete Mission"),
                        textColor: .blue,
                        systemImageName: "checkmark.circle.fill"
                    )
                    alertPresentation = AlarmPresentation.Alert(
                        title: LocalizedStringResource(stringLiteral: "Wake Up!"),
                        stopButton: stopButton,
                        secondaryButton: missionButton
                    )
                } else {
                    alertPresentation = AlarmPresentation.Alert(
                        title: LocalizedStringResource(stringLiteral: "Wake Up!"),
                        stopButton: stopButton
                    )
                }
                
                // Attributes
                let attributes = AlarmAttributes<AlarmMetadata>(
                    presentation: AlarmPresentation(alert: alertPresentation),
                    metadata: AlarmMetadata(missionType: alarm.missionType),
                    tintColor: .blue
                )
                
                // Time components
                // Time components
                let calendar = Calendar.current
                let components = calendar.dateComponents([.hour, .minute], from: alarm.time)
                guard let hour = components.hour, let minute = components.minute else {
                    print("Invalid time components")
                    return
                }

                // Время дня
                let time = AlarmKit.Alarm.Schedule.Relative.Time(hour: hour, minute: minute)

                // Дни повторения (используем 1...7)
                var weekdays: [Locale.Weekday] = []

                if !alarm.repeatDays.isEmpty {
                    let mapping: [Int: Locale.Weekday] = [
                        1: .sunday, 2: .monday, 3: .tuesday, 4: .wednesday,
                        5: .thursday, 6: .friday, 7: .saturday
                    ]
                    
                    weekdays = alarm.repeatDays.compactMap { mapping[$0] }
                }

                
                let recurrence: AlarmKit.Alarm.Schedule.Relative.Recurrence = weekdays.isEmpty ? .never : .weekly(weekdays)

                // Relative schedule
                let relative = AlarmKit.Alarm.Schedule.Relative(time: time, repeats: recurrence)

                // Финальный schedule (явно тип для избежания ambiguous ошибки)
                let schedule: AlarmKit.Alarm.Schedule = .relative(relative)
                
                // Configuration (тоже явно тип)
                let configuration: AlarmKit.AlarmManager.AlarmConfiguration<AlarmMetadata>
                if alarm.missionType != .none {
                    let missionIntent = OpenMissionIntent(
                        alarmId: alarm.id.uuidString,
                        missionType: alarm.missionType.rawValue
                    )
                    configuration = AlarmKit.AlarmManager.AlarmConfiguration(
                        schedule: schedule,
                        attributes: attributes,
                        secondaryIntent: missionIntent
                    )
                } else {
                    configuration = AlarmKit.AlarmManager.AlarmConfiguration(
                        schedule: schedule,
                        attributes: attributes
                    )
                }
                
                // Schedule the alarm
                _ = try await appAlarmManager.schedule(id: alarm.id, configuration: configuration)
                print("✅ Scheduled alarm: \(alarm.timeString)")
                
            } catch {
                print("❌ Error scheduling alarm: \(error)")
            }
        }
    }
    
    private func cancelAlarm(_ alarm: AppAlarm) {
        do {
            try appAlarmManager.cancel(id: alarm.id)
            print("🗑️ Cancelled alarm: \(alarm.timeString)")
        } catch {
            print("❌ Error cancelling alarm: \(error)")
        }
    }
    
    // MARK: - Observe Alarm Updates
    private func observeAlarmUpdates() {
        Task {
            for await updates in appAlarmManager.alarmUpdates {
                print("📡 Received \(updates.count) alarm updates from system")
                // Здесь можно синхронизировать локальные alarms с системными
            }
        }
    }
}

import ActivityKit
import AppIntents
import Foundation

struct OpenMissionIntent: LiveActivityIntent { // <- Меняем на LiveActivityIntent
    static var title: LocalizedStringResource = "Complete Mission"
    static var description = IntentDescription("Open the app to complete the alarm mission")
    
    // Это обязательное свойство для LiveActivityIntent
    static var isDestructive: Bool = false
    
    // Это заставит систему открыть приложение при нажатии на кнопку
    static var openAppWhenRun: Bool = true
    
    @Parameter(title: "Alarm ID")
    var alarmId: String
    
    @Parameter(title: "Mission Type")
    var missionType: String
    
    init() {
        self.alarmId = ""
        self.missionType = ""
    }
    
    init(alarmId: String, missionType: String) {
        self.alarmId = alarmId
        self.missionType = missionType
    }
    
    @MainActor // Добавляем, так как работаем с NotificationCenter.default
    func perform() async throws -> some IntentResult {
        print("🎯 Opening mission: \(missionType) for alarm: \(alarmId)")
        
        // В iOS 17+ и 18+ для Live Activities лучше передавать данные
        // через URL или Deep Link, но нотификация тоже сработает,
        // если приложение уже открылось в фореграунд.
        NotificationCenter.default.post(
            name: NSNotification.Name("ShowMissionScreen"),
            object: nil,
            userInfo: ["alarmId": alarmId, "missionType": missionType]
        )
        
        return .result()
    }
}

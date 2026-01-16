import Foundation
import AlarmKit

// MARK: - Alarm Metadata (for AlarmKit)
nonisolated struct AlarmMetadata: AlarmKit.AlarmMetadata {
    let missionType: MissionType
    
    init(missionType: MissionType = .none) {
        self.missionType = missionType
    }
}

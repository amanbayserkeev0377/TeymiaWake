import Foundation
import AlarmKit
import SwiftUI

// Helper to create alarm buttons
extension AlarmKit.AlarmPresentation.Alert {
    static func stopButton(text: String = "Stop") -> AlarmButton {
        return AlarmButton(
            text: LocalizedStringResource(stringLiteral: text),
            textColor: .red,
            systemImageName: "stop.fill"
        )
    }
    
    static func missionButton(text: String = "Complete Mission") -> AlarmButton {
        return AlarmButton(
            text: LocalizedStringResource(stringLiteral: text),
            textColor: .blue,
            systemImageName: "checkmark.circle.fill"
        )
    }
}

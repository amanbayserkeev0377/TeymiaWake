import Foundation

// MARK: - Mission Types
enum MissionType: String, Codable, CaseIterable {
    case none = "None"
    case math = "Math"
    case shake = "Shake"
    case rotate = "Rotate Phone"
    
    var icon: String {
        switch self {
        case .none: return "nosign"
        case .math: return "squareroot"
        case .shake: return "iphone.gen3.radiowaves.left.and.right"
        case .rotate: return "rectangle.portrait.rotate"
        }
    }
    
    var description: String {
        switch self {
        case .none: return "No mission required"
        case .math: return "Solve math problems"
        case .shake: return "Shake your phone"
        case .rotate: return "Rotate your phone"
        }
    }
}

import Foundation

struct AppAlarm: Codable, Identifiable {
    var id: UUID
    var time: Date
    var isEnabled: Bool
    var missionType: MissionType
    var repeatDays: [Int]
    var sound: String
    
    init(id: UUID = UUID(),
         time: Date = Date(),
         isEnabled: Bool = true,
         missionType: MissionType = .none,
         repeatDays: [Int] = [],
         sound: String = "Default") {
        self.id = id
        self.time = time
        self.isEnabled = isEnabled
        self.missionType = missionType
        self.repeatDays = repeatDays
        self.sound = sound
    }
    
    var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: time)
    }
    
    var repeatString: String {
        if repeatDays.isEmpty {
            return String(localized: "Once")
        } else if repeatDays.count == 7 {
            return String(localized: "Every day")
        } else {
            let calendar = Calendar.current
            let symbols = calendar.shortWeekdaySymbols // Они всегда [Sun, Mon, Tue...]
            
            // Находим первый день недели для юзера (1 для США, 2 для РФ)
            let firstDay = calendar.firstWeekday
            
            // Сортируем так, чтобы массив начинался с того дня, который у юзера в календаре первый
            let sortedDays = repeatDays.sorted { d1, d2 in
                let relativeD1 = (d1 - firstDay + 7) % 7
                let relativeD2 = (d2 - firstDay + 7) % 7
                return relativeD1 < relativeD2
            }
            
            // symbols[day - 1], потому что в массиве индексы 0...6, а наши дни 1...7
            return sortedDays.map { symbols[$0 - 1] }.joined(separator: ", ")
        }
    }
}

import SwiftUI

struct RepeatDaysView: View {
    @Binding var selectedDays: [Int]
    
    private let calendar = Calendar.current
    
    private var sortedWeekdayIndices: [Int] {
        let first = calendar.firstWeekday
        return(0..<7).map { (first + $0 - 1) % 7 + 1 }
    }
    
    var body: some View {
        HStack {
            ForEach(sortedWeekdayIndices, id: \.self) { dayIndex in
                let dayName = calendar.shortWeekdaySymbols[dayIndex - 1]
                
                Button {
                    toggleDay(dayIndex)
                } label: {
                    Circle()
                        .fill(selectedDays.contains(dayIndex) ? Color.accent : Color.secondary.opacity(0.2))
                        .frame(width: 44, height: 44)
                        .overlay(
                            Text(dayName)
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundStyle(
                                    selectedDays.contains(dayIndex) ? Color.primaryInverse : Color.primary
                                )
                        )
                }
                .buttonStyle(.plain)
                .glassEffect(
                    .regular
                    .interactive(),
                    in: Circle()
                )
            }
        }
        .sensoryFeedback(.selection, trigger: selectedDays)
    }
    
    private func toggleDay(_ day: Int) {
        if let index = selectedDays.firstIndex(of: day) {
            selectedDays.remove(at: index)
        } else {
            selectedDays.append(day)
        }
    }
}

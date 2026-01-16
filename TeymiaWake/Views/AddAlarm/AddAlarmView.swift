import SwiftUI

struct AddAlarmView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppAlarmViewModel.self) private var viewModel
    
    let alarm: AppAlarm?
    @State private var selectedTime = Date()
    @State private var selectedMission: MissionType = .none
    @State private var selectedDays: [Int] = []
    
    private var isDaily: Bool {
        selectedDays.count == 7
    }
    
    private func toggleDaily() {
        if isDaily {
            selectedDays.removeAll()
        } else {
            selectedDays = Array(1...7)
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    DatePicker("Time", selection: $selectedTime, displayedComponents: .hourAndMinute)
                        .datePickerStyle(.wheel)
                        .labelsHidden()
                }
                
                Section {
                    RepeatDaysView(selectedDays: $selectedDays)
                } header: {
                    HStack {
                        Text("Repeat")
                        
                        Spacer()
                        
                        Button {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                toggleDaily()
                            }
                        } label: {
                            HStack(spacing: 8) {
                                Text("Daily")
                                    .foregroundStyle(.primary)
                                    .fontWeight(.medium)
                                
                                Image(systemName: isDaily ? "checkmark.circle.fill" : "circle")
                                    .contentTransition(.symbolEffect(.replace))
                            }
                        }
                    }
                }
                
                
                Section("Mission") {
                    Picker("", selection: $selectedMission) {
                        ForEach(MissionType.allCases, id: \.self) { mission in
                            Label(mission.rawValue, systemImage: mission.icon)
                                .tag(mission)
                        }
                    }
                    .pickerStyle(.menu)
                }
            }
            .navigationTitle(alarm == nil ? "Add Alarm" : "Edit Alarm")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .close, action: { dismiss() }) {
                        Image(systemName: "xmark")
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(role: .confirm, action: {
                        saveAlarm()
                        dismiss()
                    }) {
                        Image(systemName: "checkmark")
                    }
                }
            }
            .onAppear {
                if let alarm = alarm {
                    selectedTime = alarm.time
                    selectedMission = alarm.missionType
                    selectedDays = alarm.repeatDays
                }
            }
        }
    }
    
    private func saveAlarm() {
        let newAlarm = AppAlarm(
            id: alarm?.id ?? UUID(),
            time: selectedTime,
            isEnabled: true,
            missionType: selectedMission,
            repeatDays: selectedDays,
            sound: "Default"
        )
        
        if alarm == nil {
            viewModel.addAlarm(newAlarm)
        } else {
            viewModel.updateAlarm(newAlarm)
        }
    }
}

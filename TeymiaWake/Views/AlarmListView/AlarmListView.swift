import SwiftUI
import AlarmKit

struct AlarmListView: View {
    @Environment(AppAlarmViewModel.self) private var viewModel
    
    @State private var editingAlarm: AppAlarm? = nil
    
    var body: some View {
        @Bindable var viewModel = viewModel
        
        NavigationStack {
            List {
                ForEach(viewModel.alarms) { alarm in
                    AlarmRow(alarm: alarm)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            editingAlarm = alarm
                        }
                }
                .onDelete { indexSet in
                    indexSet.forEach { index in
                        viewModel.deleteAlarm(viewModel.alarms[index])
                    }
                }
            }
            .overlay {
                if viewModel.alarms.isEmpty {
                    ContentUnavailableView(
                        "No Alarms",
                        systemImage: "alarm",
                        description: Text("Add a new alarm by tapping the + button")
                    )
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Alarms")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.showingAddAlarm = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $viewModel.showingAddAlarm) {
                AddAlarmView(alarm: nil)
            }
            .sheet(item: $editingAlarm) { alarm in
                AddAlarmView(alarm: alarm)
            }
            .overlay {
                if !viewModel.isAuthorized && viewModel.authorizationState == .denied {
                    VStack(spacing: 16) {
                        Image(systemName: "bell.slash")
                            .font(.system(size: 60))
                            .foregroundStyle(.red)
                        Text("Alarm Permission Denied")
                            .font(.headline)
                        Text("Please enable alarms in Settings to schedule wake-up calls")
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.secondary)
                        Button("Open Settings") {
                            if let url = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(url)
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(20)
                    .padding()
                }
            }
        }
    }
}


// MARK: - Alarm Row Component
struct AlarmRow: View {
    @Environment(AppAlarmViewModel.self) private var viewModel
    let alarm: AppAlarm
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(alarm.timeString)
                    .font(.system(size: 54, weight: .regular))
                
                HStack(spacing: 8) {
                    Text(alarm.repeatString)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    if alarm.missionType != .none {
                        Label(alarm.missionType.rawValue, systemImage: alarm.missionType.icon)
                            .font(.caption)
                            .foregroundStyle(.blue)
                    }
                }
            }
            
            Spacer()
            
            Toggle("", isOn: Binding(
                get: { alarm.isEnabled },
                set: { _ in viewModel.toggleAlarm(alarm) }
            ))
            .withToggleColor()
        }
    }
}

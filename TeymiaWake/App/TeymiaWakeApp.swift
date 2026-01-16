import SwiftUI
import AlarmKit

@main
struct TeymiaWakeApp: App {
    @State private var appAlarmViewModel = AppAlarmViewModel()
    
    var body: some Scene {
        WindowGroup {
            AlarmListView()
                .environment(appAlarmViewModel)
                .task {
                    await appAlarmViewModel.requestAuthorization()
                }
                .tint(.primary)
                .fontDesign(.rounded)
        }
    }
}

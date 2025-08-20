import ApplicationConfiguration
import SwiftUI

@main
struct homeassistant_nativeApp: App {
    var appDelegate = AppDelegate()
    let dependencies = Dependencies()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(dependencies.homeAssistantConfigurationManager)
                .environmentObject(dependencies.displayableStore)
                .environmentObject(dependencies.db)
                .environmentObject(dependencies.homeAssistant)
                .environmentObject(dependencies.octopusStore)
                .environmentObject(dependencies.displayableStore)
                .environmentObject(dependencies.entityStore)
                .environmentObject(dependencies.iconMapper)
                .environmentObject(dependencies.stateTransformer)
                .environmentObject(dependencies.iconColorTransformer)
                .environmentObject(dependencies.themeManager)
                .onAppear {
                    appDelegate.set(
                        homeAssistant: dependencies.homeAssistant,
                        entityStore: dependencies.entityStore,
                        displayableStore: dependencies.displayableStore,
                        octopusStore: dependencies.octopusStore
                    )
                }
        }
    }
}

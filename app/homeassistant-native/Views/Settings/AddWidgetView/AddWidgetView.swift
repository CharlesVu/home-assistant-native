import ApplicationConfiguration
import Foundation
import RealmSwift
import SwiftUI

class AddWidgetViewModel: ObservableObject {
    var databaseProvider: (any RealmProviding)!
    @Published var parent: DisplayableModelObject

    var path: Binding<NavigationPath>

    init(parent: DisplayableModelObject, path: Binding<NavigationPath>) {
        self.parent = parent
        self.path = path
    }

    func set(databaseProvider: any RealmProviding) {
        self.databaseProvider = databaseProvider
    }

    @MainActor
    func addButton() async {
        guard
            let parentConfiguration = databaseProvider.database().object(
                ofType: StackConfiguration.self,
                forPrimaryKey: parent.configurationID
            )
        else { return }

        do {
            let db = databaseProvider.database()
            try await db.asyncWrite {
                let configuration = ButtonConfiguration()
                db.add(configuration)

                let newButtonObject = DisplayableModelObject()
                newButtonObject.parentSection = parent.id
                newButtonObject.type = .button
                newButtonObject.configurationID = configuration.id
                db.add(newButtonObject)

                parentConfiguration.children.append(newButtonObject)
            }
            path.wrappedValue.removeLast()
        } catch {

        }
    }

    @MainActor
    func addStateDisplay() async {
        guard
            let parentConfiguration = databaseProvider.database().object(
                ofType: StackConfiguration.self,
                forPrimaryKey: parent.configurationID
            )
        else { return }

        do {
            let db = databaseProvider.database()
            try await db.asyncWrite {
                let configuration = StateDisplayConfiguration()
                db.add(configuration)

                let newButtonObject = DisplayableModelObject()
                newButtonObject.parentSection = parent.id
                newButtonObject.type = .stateDisplay
                newButtonObject.configurationID = configuration.id
                db.add(newButtonObject)

                parentConfiguration.children.append(newButtonObject)
            }
            path.wrappedValue.removeLast()
        } catch {

        }
    }

    @MainActor
    func addOctopus() async {
        guard
            let parentConfiguration = databaseProvider.database().object(
                ofType: StackConfiguration.self,
                forPrimaryKey: parent.configurationID
            )
        else { return }

        do {
            let db = databaseProvider.database()
            try await db.asyncWrite {
                let newButtonObject = DisplayableModelObject()
                newButtonObject.parentSection = parent.id
                newButtonObject.type = .octopus
                db.add(newButtonObject)

                parentConfiguration.children.append(newButtonObject)
            }
            path.wrappedValue.removeLast()
        } catch {

        }

    }

    @MainActor
    func addStack() async {
        let db = databaseProvider.database()

        guard
            let parentConfiguration = db.object(
                ofType: StackConfiguration.self,
                forPrimaryKey: parent.configurationID
            )
        else { return }

        do {
            try await db.asyncWrite {
                let configuration = StackConfiguration()
                db.add(configuration)

                let newStackObject = DisplayableModelObject()
                newStackObject.parentSection = parent.id
                newStackObject.type = .stack
                newStackObject.configurationID = configuration.id
                db.add(newStackObject)

                parentConfiguration.children.append(newStackObject)
            }
            path.wrappedValue.removeLast()
        } catch {

        }

    }

}

struct AddWidgetView: View {
    @ObservedObject var viewModel: AddWidgetViewModel
    @EnvironmentObject var databaseProvider: PersistantRealmProvider

    init(
        path: Binding<NavigationPath>,
        parent: DisplayableModelObject
    ) {
        viewModel = .init(parent: parent, path: path)
    }
    var body: some View {
        List {
            Button(
                action: {
                    Task {
                        await viewModel.addButton()
                    }
                },
                label: {
                    HADetailTextView(text: "Add Button", textAlignment: .leading)
                }
            )
            Button(
                action: {
                    Task {
                        await viewModel.addStateDisplay()
                    }
                },
                label: {
                    HADetailTextView(text: "Add Entity State", textAlignment: .leading)
                }
            )

            Button(
                action: {
                    Task {
                        await viewModel.addStack()
                    }
                },
                label: {
                    HADetailTextView(text: "Add Stack", textAlignment: .leading)
                }
            )

            Button(
                action: {
                    Task {
                        await viewModel.addOctopus()
                    }
                },
                label: {
                    HADetailTextView(text: "Add Octopus Pricing", textAlignment: .leading)
                }
            )
        }
        .onAppear {
            viewModel.set(databaseProvider: databaseProvider)
        }
    }
}

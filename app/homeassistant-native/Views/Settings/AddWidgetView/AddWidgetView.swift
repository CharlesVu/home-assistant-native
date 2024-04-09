import ApplicationConfiguration
import Factory
import Foundation
import RealmSwift
import SwiftUI

class AddWidgetViewModel: ObservableObject {
    @Injected(\.databaseManager) var databaseManager
    @Published var parent: DisplayableModelObject

    var path: Binding<NavigationPath>

    init(parent: DisplayableModelObject, path: Binding<NavigationPath>) {
        self.parent = parent
        self.path = path
    }

    @MainActor
    func addButton() async {
        guard
            let parentConfiguration = databaseManager.database().object(
                ofType: VStackConfiguration.self,
                forPrimaryKey: parent.configurationID
            )
        else { return }

        do {
            try databaseManager.database().write {
                let configuration = ButtonConfiguration()
                databaseManager.database().add(configuration)

                let newButtonObject = DisplayableModelObject()
                newButtonObject.parentSection = parent.id
                newButtonObject.type = .button
                newButtonObject.configurationID = configuration.id
                databaseManager.database().add(newButtonObject)

                parentConfiguration.children.append(newButtonObject)
            }
            path.wrappedValue.removeLast()
        } catch {

        }
    }

    @MainActor
    func addVstack() async {
        guard
            let parentConfiguration = databaseManager.database().object(
                ofType: VStackConfiguration.self,
                forPrimaryKey: parent.configurationID
            )
        else { return }

        do {
            try databaseManager.database().write {
                let configuration = VStackConfiguration()
                databaseManager.database().add(configuration)

                let newvStackObject = DisplayableModelObject()
                newvStackObject.parentSection = parent.id
                newvStackObject.type = .vStack
                newvStackObject.configurationID = configuration.id
                databaseManager.database().add(newvStackObject)

                parentConfiguration.children.append(newvStackObject)
            }
            path.wrappedValue.removeLast()
        } catch {

        }

    }

}

struct AddWidgetView: View {
    @ObservedObject var viewModel: AddWidgetViewModel

    init(
        path: Binding<NavigationPath>,
        parent: DisplayableModelObject
    ) {
        viewModel = .init(parent: parent, path: path)
    }
    var body: some View {
        VStack {
            Button("Add Button") {
                Task {
                    await viewModel.addButton()
                }
            }
            Button("Add vStack") {
                Task {
                    await viewModel.addVstack()
                }
            }
        }
    }
}

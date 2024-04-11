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
                ofType: StackConfiguration.self,
                forPrimaryKey: parent.configurationID
            )
        else { return }

        do {
            let db = databaseManager.database()
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
    func addStack() async {
        let db = databaseManager.database()

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

    init(
        path: Binding<NavigationPath>,
        parent: DisplayableModelObject
    ) {
        viewModel = .init(parent: parent, path: path)
    }
    var body: some View {
        List {
            Button("Add Button") {
                Task {
                    await viewModel.addButton()
                }
            }
            Button("Add Stack") {
                Task {
                    await viewModel.addStack()
                }
            }
        }
    }
}

//
//  SwitchWidgetView.swift
//  homeassistant-native
//
//  Created by santoru on 24/12/21.
//

import SwiftUI
import Combine

class SwitchWidgetViewModel: ObservableObject {
    @Published var icon: String = ""
    @Published var name: String?
    @Published var type: String = ""
    @Published var state: String = "off"
    let entityID: String

    private var subscriptions = Set<AnyCancellable>()

    init(entityID: String,
         subject: PassthroughSubject<EntityState, Never>) {
        self.entityID = entityID
        subject
        .filter { $0.entityId == entityID}
        .receive(on: DispatchQueue.main)
        .sink {
            self.name = $0.attributes.name
            self.state = $0.state
        }
        .store(in: &subscriptions)
    }

}

struct SwitchWidgetListView: View {
    @ObservedObject var viewModel: SwitchWidgetViewModel

    var body: some View {
        HStack {
            HAWidgetImageView(imageName: viewModel.icon)
            VStack(alignment: .leading) {
                HAMainTextView(text: viewModel.name ?? "nil")
                HAFootNoteView(text: viewModel.type.capitalized)
            }
            HABasicToggleView(viewModel.state, viewModel.entityID)

        }
    }
}

struct SwitchWidgetListView_Previews: PreviewProvider {
    static var previews: some View {
        SwitchWidgetListView(
            viewModel: .init(entityID: "test", subject: .init())
            )
    }
}

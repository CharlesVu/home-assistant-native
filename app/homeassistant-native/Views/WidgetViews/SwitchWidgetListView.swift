import Combine
import Factory
import SwiftUI

class SwitchWidgetViewModel: ObservableObject {
    @Injected(\.websocket) private var websocket

    @Published var icon: String = ""
    @Published var name: String?
    @Published var iconColor: Color = ColorManager.haDefaultDark
    @Published var state: String = "off"

    let entityID: String
    private var subscriptions = Set<AnyCancellable>()

    init(
        initialState: EntityState
    ) {
        self.entityID = initialState.entityId
        updateViewModel(entity: initialState)

        websocket.entityPublisher
            .filter { $0.entityId == initialState.entityId }
            .receive(on: DispatchQueue.main)
            .sink {
                self.updateViewModel(entity: $0)
            }
            .store(in: &subscriptions)
    }

    func updateViewModel(entity: EntityState) {
        name = entity.attributes.name
        state = entity.state
        if let icon = entity.attributes.icon {
            self.icon = IconMapper.map(haIcon: icon, state: entity.state)
        } else {
            self.icon = "lightbulb.led.wide.fill"
        }
        iconColor = IconColorTransformer.transform(entity)
    }
}

struct SwitchWidgetListView: View {
    @ObservedObject var viewModel: SwitchWidgetViewModel

    init(initialState: EntityState) {
        viewModel = .init(initialState: initialState)
    }

    var body: some View {
        HStack {
            HAWidgetImageView(imageName: viewModel.icon, color: viewModel.iconColor)
            VStack(alignment: .leading) {
                HAMainTextView(text: viewModel.name ?? "nil")
            }
            HABasicToggleView(viewModel.state, viewModel.entityID)
        }
    }
}

struct SwitchWidgetListView_Previews: PreviewProvider {
    static var previews: some View {
        SwitchWidgetListView(initialState: .zero)
    }
}

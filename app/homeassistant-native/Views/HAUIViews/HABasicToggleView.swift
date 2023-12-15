import Factory
import SwiftUI
import UIKit

class ToggleObserver: ObservableObject {
    @Injected(\.websocket) private var websocket

    private var entityId: String

    @Published var toggleValue: Bool {
        didSet {
            Task {
                try! await websocket.turnLight(on: toggleValue, entityID: entityId)
                self.isWaitingForResponse = true
            }
        }
    }

    var isWaitingForResponse = false

    init(entityId: String, toggleValue: Bool = false) {
        self.entityId = entityId
        self.toggleValue = toggleValue
    }

    static func computeToggleStatus(state: String) -> Bool {
        state == "on" ? true : false
    }
}

struct HABasicToggleView: View {
    @ObservedObject var viewModel: ToggleObserver
    private let haptic = UINotificationFeedbackGenerator()

    init(_ state: String, _ entityId: String) {
        viewModel = .init(
            entityId: entityId,
            toggleValue: ToggleObserver.computeToggleStatus(state: state)
        )
    }

    var body: some View {
        if viewModel.isWaitingForResponse {
            ProgressView()
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.trailing)
        } else {
            Toggle(
                isOn: $viewModel.toggleValue,
                label: {
                    Text("")
                }
            )
            .labelsHidden()
            .frame(maxWidth: .infinity, alignment: .trailing)
            .toggleStyle(PowerToggleStyle())
            .padding(.trailing)
            .onTapGesture {
                self.haptic.notificationOccurred(.success)
            }
        }
    }
}

struct HABasicToggleView_Previews: PreviewProvider {
    static var previews: some View {
        HABasicToggleView("on", "dummy_id")
    }
}

struct PowerToggleStyle: ToggleStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        return HStack {
            configuration.label
            Spacer()
            Image(systemName: configuration.isOn ? "power.circle.fill" : "circle")
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundColor(
                    configuration.isOn ? ColorManager.haDefaultDark : ColorManager.haDefaultLighter
                )
                .font(.system(size: 20, weight: .bold, design: .default))
                .onTapGesture {
                    configuration.isOn.toggle()
                }
        }
    }
}

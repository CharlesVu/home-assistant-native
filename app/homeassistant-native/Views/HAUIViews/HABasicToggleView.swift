import ApplicationConfiguration
import Combine
import Factory
import RealmSwift
import SwiftUI

class ToggleObserver: ObservableObject {
    @Injected(\.homeAssistant) private var homeAssistant

    private var entity: Entity
    private var requestId: Int = 0
    private var subscriptions = Set<AnyCancellable>()

    @Published var isWaitingForResponse = false
    @Published var toggleValue: Bool {
        didSet {
            Task {
                await self.toggleLight()
            }
        }
    }

    @MainActor
    func toggleLight() async {
        if requestId == 0 {
            requestId = try! await homeAssistant.turnLight(
                on: toggleValue,
                entityID: entity.id
            )
            isWaitingForResponse = true
            homeAssistant.responsePublisher
                .receive(on: DispatchQueue.main)
                .filter { $0.id == self.requestId }
                .prefix(1)
                .sink { [weak self] _ in
                    guard let self else { return }
                    self.isWaitingForResponse = false
                    self.requestId = 0
                }.store(in: &subscriptions)
        }
    }

    init(entity: Entity) {
        self.entity = entity
        self.toggleValue = Self.computeToggleStatus(state: entity.state)
    }

    static func computeToggleStatus(state: String) -> Bool {
        state == "on" ? true : false
    }
}

struct HABasicToggleView: View {
    @ObservedObject var viewModel: ToggleObserver
    @ObservedRealmObject var entity: Entity

    private let haptic = UINotificationFeedbackGenerator()

    init(entity: Entity) {
        viewModel = .init(
            entity: entity
        )
        self.entity = entity
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

struct PowerToggleStyle: ToggleStyle {
    @EnvironmentObject private var themeManager: ThemeManager

    func makeBody(configuration: Self.Configuration) -> some View {
        return HStack {
            configuration.label
            Spacer()
            Image(systemName: configuration.isOn ? "power.circle.fill" : "circle")
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundColor(
                    configuration.isOn ? themeManager.current.text : themeManager.current.lightText
                )
                .font(.system(size: 20, weight: .bold, design: .default))
                .onTapGesture {
                    configuration.isOn.toggle()
                }
        }
    }
}

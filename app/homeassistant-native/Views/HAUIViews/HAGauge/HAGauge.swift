import SwiftUI

struct HAGauge: View {
    @ObservedObject var viewModel: HAGaugeViewModel
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var stateTransformer: StateTransformer
    @EnvironmentObject private var entityStore: EntityStore

    init(entityID: String) {
        viewModel = .init(entityID: entityID)
    }

    var body: some View {
        VStack {
            Gauge(
                value: viewModel.currentValue,
                in: viewModel.minValue...viewModel.maxValue,
                label: {},
                currentValueLabel: {
                    Text(viewModel.displayableValue)
                        .foregroundColor(themeManager.current.text)
                }
            )
            .gaugeStyle(.accessoryCircular)
            .tint(
                Gradient(colors: [
                    themeManager.current.green,
                    themeManager.current.orange,
                    themeManager.current.red,
                ])
            )
            .scaledToFill()

            HAFootNoteView(
                text: viewModel.title,
                alignement: .center
            )
        }.onAppear {
            viewModel.set(
                stateFormatter: stateTransformer,
                entityStore: entityStore
            )
        }
    }
}

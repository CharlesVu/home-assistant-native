import SwiftUI

struct HAGauge: View {
    @ObservedObject var viewModel: HAGaugeViewModel

    let gradient = Gradient(colors: [
        ColorManager.green,
        ColorManager.orange,
        ColorManager.red,
    ])

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
                        .foregroundColor(ColorManager.haDefaultDark)
                }
            )
            .gaugeStyle(.accessoryCircular)
            .tint(gradient)
            .scaledToFill()

            HAFootNoteView(
                text: viewModel.title,
                alignement: .center
            )
        }
    }
}

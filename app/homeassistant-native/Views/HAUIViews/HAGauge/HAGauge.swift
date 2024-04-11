import SwiftUI

struct HAGauge: View {
    @ObservedObject var viewModel: HAGaugeViewModel
    @EnvironmentObject private var themeManager: ThemeManager

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
        }
    }
}

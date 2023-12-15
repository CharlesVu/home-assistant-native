import Combine
import SwiftUI

class HeaderViewModel: ObservableObject {
    let temperatureHumidityWidgetViewModel: TemperatureHumidityWidgetViewModel

    init() {
        temperatureHumidityWidgetViewModel = .init()
    }
}

struct HeaderView: View {
    @State var showSettings = false
    @ObservedObject var viewModel: HeaderViewModel

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                HATitleTextView(
                    text: "Citadel",
                    icon: "house.fill"
                )

                Button(action: {
                    self.showSettings = true
                }) {
                    Image(systemName: "gear")
                        .foregroundColor(ColorManager.haDefaultDark)
                        .font(.title)
                }
                .frame(alignment: .trailing)
                .sheet(
                    isPresented: $showSettings,
                    content: {
                        ModalSettingsView()
                    }
                )
            }
            .padding()
            TemperatureHumidityWidgetView(viewModel: viewModel.temperatureHumidityWidgetViewModel)
        }
    }
}

struct HeaderView_Previews: PreviewProvider {
    static var previews: some View {
        HeaderView(viewModel: .init())
    }
}

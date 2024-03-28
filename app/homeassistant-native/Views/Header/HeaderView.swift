import Combine
import SwiftUI

struct HeaderView: View {
    @State var showSettings = false

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
            TemperatureHumidityWidgetView()
        }
    }
}

struct HeaderView_Previews: PreviewProvider {
    static var previews: some View {
        HeaderView()
    }
}

//
//  HeaderView.swift
//  homeassistant-native
//
//  Created by santoru on 24/12/21.
//

import SwiftUI
import Combine

class HeaderViewModel: ObservableObject {
    let temperatureHumidityWidgetViewModel: TemperatureHumidityWidgetViewModel

    init(subject: PassthroughSubject<EntityState, Never>) {
        temperatureHumidityWidgetViewModel = .init(subject: subject)
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
                    icon: "house.fill")

                Button(action: {
                    self.showSettings = true
                }) {
                    Image(systemName: "gear")
                        .foregroundColor(ColorManager.haDefaultDark)
                        .font(.title)
                }
                .frame(alignment: .trailing)
                .sheet(isPresented: $showSettings, content: {
                    ModalSettingsView()
                })
            }
            .padding()
            TemperatureHumidityWidgetView(viewModel: viewModel.temperatureHumidityWidgetViewModel)
        }
    }
}

struct HeaderView_Previews: PreviewProvider {
    static var previews: some View {
        HeaderView(viewModel: .init(subject: .init()))
    }
}

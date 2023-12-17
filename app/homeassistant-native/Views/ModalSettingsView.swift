import SwiftUI

struct ModalSettingsView: View {

    @Environment(\.presentationMode)
    var presentationMode: Binding<PresentationMode>

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 0) {
                HATitleTextView(text: "Settings", icon: "gear")
                .padding()
                List {
                    Section {
                        NavigationLink {
                            HomeAssistantSettingsView()
                        } label: {
                            HASettingItemView(
                                text: "Home Assistant",
                                icon: "house.fill",
                                foregroundColor: .blue,
                                backgroundColor: .white
                            )
                        }
                        HASettingItemView(
                            text: "Appearance",
                            icon: "textformat.size",
                            foregroundColor: .white,
                            backgroundColor: .blue
                        )
                        HASettingItemView(
                            text: "Networking",
                            icon: "globe",
                            foregroundColor: .white,
                            backgroundColor: .green
                        )
                        HASettingItemView(
                            text: "Rate me",
                            icon: "heart.fill",
                            foregroundColor: .white,
                            backgroundColor: .red
                        )
                    }
                }
            }
            #if !os(macOS)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing:
                    Button(
                        "Dismiss",
                        action: {
                            self.presentationMode.wrappedValue.dismiss()
                        }
                    ).accentColor(ColorManager.haDefaultDark)
            )
            #endif
        }
        .background(Color(.systemGray))

    }
}

struct ModalSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        ModalSettingsView()
    }
}

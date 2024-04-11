import SwiftUI

struct HATitleTextView: View {
    @EnvironmentObject private var themeManager: ThemeManager

    var text: String
    var icon: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(Font.title.weight(.bold))
            Text(text)
                .fontWeight(.bold)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .font(.largeTitle)
        .foregroundColor(themeManager.current.text)
    }
}

struct HATitleTextView_Previews: PreviewProvider {
    static var previews: some View {
        HATitleTextView(text: "Test", icon: "house.fill")
    }
}

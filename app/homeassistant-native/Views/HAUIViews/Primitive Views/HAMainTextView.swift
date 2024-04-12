import SwiftUI

struct HAMainTextView: View {
    @EnvironmentObject private var themeManager: ThemeManager

    var text: String
    var body: some View {

        Text(text)
            .fontWeight(.medium)
            .foregroundColor(themeManager.current.text)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct HAMainTextView_Previews: PreviewProvider {
    static var previews: some View {
        HAMainTextView(text: "Test")
    }
}

import SwiftUI

struct HADetailTextView: View {
    @EnvironmentObject private var themeManager: ThemeManager

    var text: String
    var textAlignment: Alignment

    var body: some View {
        Text(text)
            .fontWeight(.medium)
            .foregroundColor(themeManager.current.text)
            .frame(maxWidth: .infinity, alignment: textAlignment)
    }
}

struct HADetailTextView_Previews: PreviewProvider {
    static var previews: some View {
        HADetailTextView(text: "Test", textAlignment: .trailing)
    }
}

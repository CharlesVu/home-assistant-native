import SwiftUI

struct HABasicIconView: View {
    @EnvironmentObject private var themeManager: ThemeManager

    var icon: String
    var darkColorScheme: Bool = true

    var body: some View {
        Image(systemName: icon)
            .foregroundColor(themeManager.current.text)
    }
}

struct HABasicIconView_Previews: PreviewProvider {
    static var previews: some View {
        HABasicIconView(icon: "gear")
    }
}

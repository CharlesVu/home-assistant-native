import SwiftUI

struct HASettingItemView: View {
    @EnvironmentObject private var themeManager: ThemeManager

    var text: String
    var icon: String
    var foregroundColor: Color
    var backgroundColor: Color

    var body: some View {
        HStack {
            Image(systemName: icon)
                .frame(width: 25, height: 25)
                .background(backgroundColor)
                .foregroundColor(foregroundColor)
                .cornerRadius(5)
            Text(text)
                .foregroundStyle(themeManager.current.text)
        }
    }
}

struct HASettingItemView_Previews: PreviewProvider {
    static var previews: some View {
        HASettingItemView(text: "Test", icon: "globe", foregroundColor: .white, backgroundColor: .blue)
    }
}

import SwiftUI

struct HAWidgetImageView: View {
    @EnvironmentObject private var themeManager: ThemeManager

    var imageName: String
    var color: Color

    var body: some View {
        Image(systemName: imageName)
            .renderingMode(.template)
            .frame(width: 42, height: 42)
            .font(.system(size: 24.0).bold())
            .foregroundColor(color)
            .cornerRadius(5)
    }
}

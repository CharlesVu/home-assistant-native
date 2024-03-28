import SwiftUI

struct HAWidgetImageView: View {
    var imageName: String
    var color: Color = ColorManager.haDefaultDark
    var body: some View {
        Image(systemName: imageName)
            .renderingMode(.template)
            .frame(width: 42, height: 42)
            .font(.system(size: 24.0).bold())
            .foregroundColor(color)
            .cornerRadius(5)
    }
}

struct HAWidgetImageView_Previews: PreviewProvider {
    static var previews: some View {
        HAWidgetImageView(imageName: "lightbulb")
    }
}

import SwiftUI

struct HADetailTextView: View {
    var text: String
    var darkColorScheme: Bool = true
    var body: some View {
        let color: Color = darkColorScheme ? ColorManager.haDefaultDark : ColorManager.haDefaultLighter

        Text(text)
            .fontWeight(.medium)
            .foregroundColor(color)
            .frame(maxWidth: .infinity, alignment: .trailing)
    }
}

struct HADetailTextView_Previews: PreviewProvider {
    static var previews: some View {
        HADetailTextView(text: "Test")
    }
}

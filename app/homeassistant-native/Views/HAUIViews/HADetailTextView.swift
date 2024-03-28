import SwiftUI

struct HADetailTextView: View {
    var text: String
    var body: some View {
        Text(text)
            .fontWeight(.medium)
            .foregroundColor(ColorManager.haDefaultDark)
            .frame(maxWidth: .infinity, alignment: .trailing)
    }
}

struct HADetailTextView_Previews: PreviewProvider {
    static var previews: some View {
        HADetailTextView(text: "Test")
    }
}

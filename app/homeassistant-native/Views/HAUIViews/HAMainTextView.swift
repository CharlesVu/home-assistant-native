import SwiftUI

struct HAMainTextView: View {
    var text: String
    var body: some View {

        Text(text)
            .fontWeight(.medium)
            .foregroundColor(ColorManager.haDefaultDark)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct HAMainTextView_Previews: PreviewProvider {
    static var previews: some View {
        HAMainTextView(text: "Test")
    }
}

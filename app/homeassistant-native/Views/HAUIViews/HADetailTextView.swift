import SwiftUI

struct HADetailTextView: View {
    var text: String
    var textAlignment: Alignment

    var body: some View {
        Text(text)
            .fontWeight(.medium)
            .foregroundColor(ColorManager.haDefaultDark)
            .frame(maxWidth: .infinity, alignment: textAlignment)
    }
}

struct HADetailTextView_Previews: PreviewProvider {
    static var previews: some View {
        HADetailTextView(text: "Test", textAlignment: .trailing)
    }
}

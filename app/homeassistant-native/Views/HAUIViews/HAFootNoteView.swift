import SwiftUI

struct HAFootNoteView: View {
    var text: String
    var body: some View {
        Text(text)
            .font(.footnote)
            .fontWeight(.light)
            .foregroundColor(ColorManager.haDefaultLight)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct HAFootNoteView_Previews: PreviewProvider {
    static var previews: some View {
        HAFootNoteView(text: "Test")
    }
}

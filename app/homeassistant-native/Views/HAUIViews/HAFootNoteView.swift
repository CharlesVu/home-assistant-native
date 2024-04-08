import SwiftUI

struct HAFootNoteView: View {
    var text: String
    var alignement: Alignment

    var body: some View {
        Text(text)
            .font(.footnote)
            .fontWeight(.light)
            .foregroundColor(ColorManager.haDefaultLight)
            .frame(maxWidth: .infinity, alignment: alignement)
    }
}

struct HAFootNoteView_Previews: PreviewProvider {
    static var previews: some View {
        HAFootNoteView(text: "Test", alignement: .leading)
    }
}

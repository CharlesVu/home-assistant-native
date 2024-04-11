import SwiftUI

struct HAFootNoteView: View {
    @EnvironmentObject private var themeManager: ThemeManager

    var text: String
    var alignement: Alignment

    var body: some View {
        Text(text)
            .font(.footnote)
            .fontWeight(.light)
            .foregroundColor(themeManager.current.text)
            .frame(maxWidth: .infinity, alignment: alignement)
    }
}

struct HAFootNoteView_Previews: PreviewProvider {
    static var previews: some View {
        HAFootNoteView(text: "Test", alignement: .leading)
    }
}

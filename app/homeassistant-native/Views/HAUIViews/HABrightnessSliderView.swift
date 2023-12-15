import SwiftUI

struct HABrightnessSliderView: View {
    @State private var isEditing = false
    @State private var brightness = 50.0

    var body: some View {
        VStack {
            HStack {
                HABasicIconView(icon: "light.min")
                Slider(
                    value: $brightness,
                    in: 0...100,
                    step: 1,
                    onEditingChanged: { editing in
                        isEditing = editing
                    }
                ).accentColor(ColorManager.haDefaultDark)
                HABasicIconView(icon: "light.max")
            }
            Text("\(Int(brightness))")
                .foregroundColor(isEditing ? ColorManager.haDefaultLight : ColorManager.haDefaultDark)
                .padding()
        }
    }
}

struct HaBrightnessSliderView_Previews: PreviewProvider {
    static var previews: some View {
        HABrightnessSliderView()
    }
}

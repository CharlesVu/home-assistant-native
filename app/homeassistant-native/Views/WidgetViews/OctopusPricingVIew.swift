import SwiftUI

struct OctopusPricingVIew: View {
    var date: Date
    var price: Double
    var meanPrice: Double

    var body: some View {
        HStack {
            HAWidgetImageView(
                imageName: iconName(price: price),
                color: color(price: price)
            )

            VStack {
                HAFootNoteView(text: "\(date.octopusFormatted)")

                Text("\((price * 100).priceFormatted())p")
                    .fontWeight(.medium)
                    .foregroundColor(ColorManager.haDefaultDark)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    func color(price: Double) -> Color {
        if price <= 0 {
            return ColorManager.blue
        } else if price <= meanPrice {
            return ColorManager.green
        } else {
            return ColorManager.orange
        }
    }

    func iconName(price: Double) -> String {
        return "bolt.horizontal.circle.fill"
    }
}

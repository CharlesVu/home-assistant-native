import SwiftUI

struct OctopusPricingView: View {
    @EnvironmentObject private var themeManager: ThemeManager

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
                HAFootNoteView(text: "\(date.octopusFormatted)", alignement: .leading)

                Text("\((price * 100).priceFormatted())p")
                    .fontWeight(.medium)
                    .foregroundColor(themeManager.current.text)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    func color(price: Double) -> Color {
        if price <= 0 {
            return themeManager.current.blue
        } else if price <= meanPrice {
            return themeManager.current.green
        } else {
            return themeManager.current.orange
        }
    }

    func iconName(price: Double) -> String {
        return "bolt.horizontal.circle.fill"
    }
}

extension DateFormatter {
    fileprivate static var octopusDsiplayDateFormatter: DateFormatter {
        let dateFomatter = DateFormatter()
        dateFomatter.calendar = Calendar(identifier: .iso8601)
        dateFomatter.locale = Locale(identifier: "en_US_POSIX")
        dateFomatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFomatter.dateFormat = "E HH:mm"
        return dateFomatter
    }
}

extension Date {
    fileprivate var octopusFormatted: String {
        DateFormatter.octopusDsiplayDateFormatter.string(from: self)
    }
}

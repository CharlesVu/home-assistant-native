import Foundation
import SwiftUI

class ThemeManager: ObservableObject {
    @Published var current: Theme = .init(themeName: "Cognac")
}

struct Theme {
    init(themeName: String) {
        background = Color("\(themeName)/background")
        lightBackground = Color("\(themeName)/lightBackground")
        blue = Color("\(themeName)/blue")
        green = Color("\(themeName)/green")
        lightText = Color("\(themeName)/lightText")
        orange = Color("\(themeName)/orange")
        red = Color("\(themeName)/red")
        text = Color("\(themeName)/text")
        yellow = Color("\(themeName)/yellow")
    }

    let background: Color
    let lightBackground: Color
    let blue: Color
    let green: Color
    let lightText: Color
    let orange: Color

    let red: Color
    let text: Color
    let yellow: Color
}

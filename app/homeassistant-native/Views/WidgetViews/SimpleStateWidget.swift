import Combine
import Factory
import ApplicationConfiguration
import SwiftUI
import RealmSwift

struct SimpleStateWidget: View {
    @ObservedRealmObject var entity: Entity

    init(entity: Entity) {
        self.entity = entity
    }

    var body: some View {
        HStack {
            HAWidgetImageView(
                imageName: entity.icon!,
                color: IconColorTransformer.transform(entity)
            )
            VStack(alignment: .leading) {
                HAMainTextView(text: entity.displayName())
            }
            HADetailTextView(text: entity.state)
        }
    }
}

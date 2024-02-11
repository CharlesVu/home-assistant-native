import Combine
import Factory
import ApplicationConfiguration
import SwiftUI
import RealmSwift

struct SimpleStateWidget: View {
    @ObservedRealmObject var entity: EntityModelObject

    init(entity: EntityModelObject) {
        self.entity = entity
    }

    var body: some View {
        HStack {
            HAWidgetImageView(
                imageName: entity.attributes!.icon!,
                color: IconColorTransformer.transform(entity)
            )
            VStack(alignment: .leading) {
                HAMainTextView(text: entity.displayName())
            }
            HADetailTextView(text: entity.state)
        }
    }
}

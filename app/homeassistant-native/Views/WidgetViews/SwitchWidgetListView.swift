import ApplicationConfiguration
import Combine
import Factory
import RealmSwift
import SwiftUI

struct SwitchWidgetListView: View {
    @ObservedRealmObject var entity: Entity
    init(entity: Entity) {
        self.entity = entity
    }

    var body: some View {
        HStack {
            HAWidgetImageView(
                imageName: IconMapper().map(entity: entity),
                color: IconColorTransformer.transform(entity)
            )
            VStack(alignment: .leading) {
                HAMainTextView(text: entity.displayName())
            }
            HABasicToggleView(entity: entity)
        }
    }
}

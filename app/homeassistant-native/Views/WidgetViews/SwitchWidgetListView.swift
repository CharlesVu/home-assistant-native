import Combine
import Factory
import ApplicationConfiguration
import SwiftUI
import RealmSwift

struct SwitchWidgetListView: View {
    @ObservedRealmObject var entity: EntityModelObject

    init(entity: EntityModelObject) {
        self.entity = entity
    }

    var body: some View {
        HStack {
            HAWidgetImageView(imageName: IconMapper.map(entity: entity),
                              color: IconColorTransformer.transform(entity))
            VStack(alignment: .leading) {
                HAMainTextView(text: entity.displayName())
            }
            HABasicToggleView(entity: entity)
        }
    }
}

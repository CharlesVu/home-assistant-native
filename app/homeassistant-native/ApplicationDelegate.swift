import ApplicationConfiguration
import Combine
import Factory
import Foundation
import HomeAssistant
import RealmSwift
import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
    @Injected(\.homeAssistant) private var homeAssistant
    @Injected(\.databaseManager) private var databaseManager

    var subscriptions = Set<AnyCancellable>()

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        homeAssistant
            .entityPublisher
            .sink { [weak self] entityState in
                self?.updateEntity(newState: entityState)
            }
            .store(in: &subscriptions)

        homeAssistant
            .octopusPublisher
            .sink { [weak self] rates in
                self?.updateRates(newRates: rates)
            }
            .store(in: &subscriptions)

        return true
    }

    func updateRates(newRates: [OctopusRate]) {
        print("Updated Octupus Rates")
        let db = databaseManager.database()
        try? db.write {
            // db.delete(db.objects(OctopusRateModelObject.self))
            newRates.forEach {
                let rate = OctopusRateModelObject(
                    start: $0.start,
                    end: $0.end,
                    price: $0.value
                )
                db.add(rate, update: .modified)
            }
        }
    }

    func updateEntity(newState: EntityState) {
        let db = databaseManager.database()
        var model: EntityModelObject
        if let existingModel = db.object(
            ofType: EntityModelObject.self,
            forPrimaryKey: newState.entityId
        ) {
            model = existingModel
        } else {
            model = .init()
            model.entityID = newState.entityId
        }

        try? db.write {
            model.state = newState.state
            model.attributes.update(newState.attributes)
            db.add(model, update: .modified)
        }
    }
}

extension EntityAttributeModelObject {
    func update(_ model: EntityAttribute) {
        self.unit = model.unit
        self.name = model.name
        if let deviceClass = model.deviceClass {
            self.deviceClass = .init(rawValue: deviceClass)
        }
        self.stateClass = model.stateClass
        self.temperature = model.temperature
        self.humidity = model.humidity
        self.windSpeed = model.windSpeed
        self.icon = model.icon
        if let rgb = model.rgb {
            self.rgb = List()
            rgb.forEach { self.rgb.append($0) }
        }
        if let hs = model.hs {
            self.hs = List()
            hs.forEach { self.hs.append($0) }
        }
        self.brightness = model.brightness
        self.hueType = model.hueType
    }
}

import Foundation
import RealmSwift

public enum DeviceClass: String, PersistableEnum {
    case date = "date"
    case enumeration = "enum"
    case timestamp = "timestamp"
    case apparentPower = "apparent_power"
    case aqi = "aqi"
    case atmosphericPressure = "atmospheric_pressure"
    case battery = "battery"
    case batteryCharging = "battery_charging"
    case carbonMonoxide = "carbon_monoxide"
    case carbonDioxide = "carbon_dioxide"
    case connectivity
    case current = "current"
    case dataRate = "data_rate"
    case dataSize = "data_size"
    case distance = "distance"
    case door
    case duration = "duration"
    case energy = "energy"
    case energyStorage = "energy_storage"
    case frequency = "frequency"
    case gas = "gas"
    case heat
    case humidity = "humidity"
    case illuminance = "illuminance"
    case irradiance = "irradiance"
    case light
    case lock
    case moisture = "moisture"
    case monetary = "monetary"
    case motion
    case moving
    case nitrogenDioxide = "nitrogen_dioxide"
    case nitrogenMonoxide = "nitrogen_monoxide"
    case nitrousOxide = "nitrous_oxide"
    case occupancy
    case opening
    case ozone = "ozone"
    case ph = "ph"
    case plug
    case pm1 = "pm1"
    case pm10 = "pm10"
    case pm25 = "pm25"
    case powerFactor = "power_factor"
    case power = "power"
    case precipitation = "precipitation"
    case precipitationIntensity = "precipitation_intensity"
    case pressure = "pressure"
    case reactivePower = "reactive_power"
    case running
    case safety
    case signalStrength = "signal_strength"
    case smoke
    case soundPressure = "sound_pressure"
    case speed = "speed"
    case sulphurDioxide = "sulphur_dioxide"
    case temperature = "temperature"
    case window
    case volatileOrganicCompounds = "volatile_organic_compounds"
    case volatileOrganicCompoundsParts = "volatile_organic_compounds_parts"
    case voltage = "voltage"
    case volume = "volume"
    case volumeStorage = "volume_storage"
    case volumeFlowRate = "volume_flow_rate"
    case water = "water"
    case weight = "weight"
    case windSpeed = "wind_speed"
}

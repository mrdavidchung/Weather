//
//  CityWeather.swift
//  Weather
//
//  Created by David Chung on 8/1/18.
//

import Foundation

class CityWeather : NSObject, NSCoding {
    
    var city: String = ""
    var state: String = ""
    var zip: String = ""
    var temperature: String = ""
    var humidity: String = ""
    var pressure: String = ""
    var high: String = ""
    var low: String = ""
    var lastUpdated: Date = Date()
    
    override init() {
    }
    
    init(city: String, state: String, zip: String, temperature: String, humidity: String, pressure: String, high: String, low: String, lastUpdated: Date) {
        self.city = city
        self.state = state
        self.zip = zip
        self.temperature = temperature
        self.humidity = humidity
        self.pressure = pressure
        self.high = high
        self.low = low
        self.lastUpdated = lastUpdated
    }
    
    required convenience init?(coder decoder: NSCoder) {
        guard let city = decoder.decodeObject(forKey: "city") as? String,
        let state = decoder.decodeObject(forKey: "state") as? String,
        let zip = decoder.decodeObject(forKey: "zip") as? String,
        let temperature = decoder.decodeObject(forKey: "temperature") as? String,
        let humidity = decoder.decodeObject(forKey: "humidity") as? String,
        let pressure = decoder.decodeObject(forKey: "pressure") as? String,
        let high = decoder.decodeObject(forKey: "high") as? String,
        let low = decoder.decodeObject(forKey: "low") as? String,
        let lastUpdated = decoder.decodeObject(forKey: "lastUpdated") as? Date
        else {
            return nil
        }
        
        self.init(
            city: city,
            state: state,
            zip: zip,
            temperature: temperature,
            humidity: humidity,
            pressure: pressure,
            high: high,
            low: low,
            lastUpdated: lastUpdated
        )
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(self.city, forKey: "city")
        coder.encode(self.state, forKey: "state")
        coder.encode(self.zip, forKey: "zip")
        coder.encode(self.temperature, forKey: "temperature")
        coder.encode(self.humidity, forKey: "humidity")
        coder.encode(self.pressure, forKey: "pressure")
        coder.encode(self.high, forKey: "high")
        coder.encode(self.low, forKey: "low")
        coder.encode(self.lastUpdated, forKey: "lastUpdated")
    }
    
    func place() -> String {
        return "\(city), \(state)"
    }
}

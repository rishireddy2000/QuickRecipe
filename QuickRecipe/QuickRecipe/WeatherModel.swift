import Foundation

struct WeatherData: Codable {
    let weather: [Weather]
    let main: Main
    let name: String
}

struct Weather: Codable {
    let id: Int
}

struct Main: Codable {
    let temp: Double
}

struct WeatherModel {
    let id: Int
    let temp: Double
    let cityName: String
}

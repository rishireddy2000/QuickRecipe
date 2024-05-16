//
//  WeatherManager.swift
//  MixnMatch
//
//  Created by Prudhvi Puli on 06/03/24.


import Foundation
import SwiftUI
import CoreLocation

/// Manages weather data fetching and parsing.
struct WeatherManager {
    /// The base URL for the OpenWeatherMap API.
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=c6d93d5fce873ab9bd6c948d493c9dbb&units=metric"
    
    /// Fetches weather data for a given city name.
    /// - Parameters:
    ///   - cityName: The name of the city to fetch weather data for.
    ///   - completion: A closure to call with the result of the fetch operation.
    func fetchWeather(cityName: String, completion: @escaping (Result<WeatherModel, Error>) -> Void) {
        let urlString = "\(weatherURL)&q=\(cityName)"
        performRequest(with: urlString) { result in
            completion(result)
        }
    }

    /// Performs a network request to fetch weather data.
    /// - Parameters:
    ///   - urlString: The URL string to use for the request.
    ///   - completion: A closure to call with the result of the request.
    private func performRequest(with urlString: String, completion: @escaping (Result<WeatherModel, Error>) -> Void) {
        print("Performing request for URL: \(urlString)")
        guard let url = URL(string: urlString) else {
            print("Invalid URL:", urlString)
            completion(.failure(URLError(.badURL)))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("Error performing request:", error.localizedDescription)
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                print("No data received from server.")
                completion(.failure(URLError(.badServerResponse)))
                return
            }
            
            do {
                let decodedData = try JSONDecoder().decode(WeatherData.self, from: data)
                let weatherModel = WeatherModel(
                    id: decodedData.weather.first?.id ?? 0,
                    temp: decodedData.main.temp,
                    cityName: decodedData.name
                )
                print("Weather data fetched successfully.")
                completion(.success(weatherModel))
            } catch {
                print("Error decoding weather data:", error.localizedDescription)
                completion(.failure(error))
            }
        }.resume()
    }
    
    /// Parses weather data from JSON into a `WeatherModel` object.
    /// - Parameter weatherData: The raw weather data in JSON format.
    /// - Returns: A `WeatherModel` object parsed from the JSON data, or nil if parsing fails.
    private func parseJSON(weatherData: Data) -> WeatherModel? {
        print("Parsing weather JSON data.")
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let id = decodedData.weather[0].id
            let temp = decodedData.main.temp
            let name = decodedData.name
            
            return WeatherModel(id: id, temp: temp, cityName: name)
        } catch {
            print("Error parsing weather JSON:", error.localizedDescription)
            return nil
        }
    }
}




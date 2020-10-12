//
//  WeatherManager.swift
//  Clima
//
//  Created by Oleksandr Hozhulovskyi on 24.01.2020.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import Foundation
import CoreLocation

struct WeatherManager {
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=8dea8ee1f69e858c5389a53052d2b5cb&units=metric"
    
    func fetchWeather(cityName: String, completion: @escaping (Result<WeatherModel, Error>) -> Void) {
        let urlString = "\(weatherURL)&q=\(cityName)"
        performRequest(urlString, completion: completion)
    }
    
    func fetchWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees, completion: @escaping (Result<WeatherModel, Error>) -> Void) {
        let urlString = "\(weatherURL)&lat=\(latitude)&lon=\(longitude)"
        performRequest(urlString, completion: completion)
    }

    private func parseJSON(weatherData: Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        
        guard let decodedData = try? decoder.decode(WeatherData.self, from: weatherData) else { return nil }
        
        let id = decodedData.weather[0].id
        let temp = decodedData.main.temp
        let name = decodedData.name
        
        return WeatherModel(conditionId: id, cityName: name, temperature: temp)
    }
    
    private func performRequest(_ urlString: String, completion: @escaping (Result<WeatherModel, Error>) -> Void) {
        guard let url = URL(string: urlString) else { return }
        
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: url) { (data, response, error) in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
            
            guard let data = data else { return }
            guard let weather = self.parseJSON(weatherData: data) else { return }
            
            DispatchQueue.main.async {
                completion(.success(weather))
            }
        }
        task.resume()
    }
}

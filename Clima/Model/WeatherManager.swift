//
//  WeatherManager.swift
//  Clima
//
//  Created by Hasaan Butt on 11/01/2022.
//

import Foundation
import CoreLocation

protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel)
    func didFailWithError(error: Error)
}

struct WeatherManager {
    
    var delegate: WeatherManagerDelegate?
    
    var url = "https://api.openweathermap.org/data/2.5/weather?appid=c4e7ebe63f7d79a772c103afb33ac6ba&units=metric"
    
    func fetchWeatherDetails(cityName: String) {
        let urlString = "\(url)&q=\(cityName)"
        //        print(urlString)
        performTask(with: urlString)
    }
    
    func fetchWeatherDetails(lat: CLLocationDegrees, lon: CLLocationDegrees) {
        let urlString = "\(url)&lat=\(lat)&lon=\(lon)"
        //        print(urlString
        performTask(with: urlString)
    }
    
    func performTask(with urlString: String) {
        
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url, completionHandler: { (data: Data?, urlResponse: URLResponse?, error: Error?) in
                if error != nil {
                    delegate?.didFailWithError(error: error!)
                    return
                } 
                
                if let safeData = data {
                    if let weather = parseJSON(safeData) {
                        delegate?.didUpdateWeather(self, weather: weather)
                    }
                }
            })
            task.resume()
        }
        
    }
    
    func parseJSON(_ data: Data) -> WeatherModel? {
        
        let decoder = JSONDecoder()
        
        do {
            let decodedData = try decoder.decode(WeatherData.self, from: data)
            let id = decodedData.weather[0].id
            let temp = decodedData.main.temp
            let city = decodedData.name
            
            let weather = WeatherModel(conditionId: id, cityName: city, temperature: temp)
            
            return weather
            
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
        
    }
    
}


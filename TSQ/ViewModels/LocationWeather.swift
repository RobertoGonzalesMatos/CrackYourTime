//
//  LocationWeather.swift
//  TSQ
//
//  Created by Roberto Gonzales on 8/19/23.
//

import Foundation
import CoreLocation
import UIKit

final class locationController: NSObject, ObservableObject, CLLocationManagerDelegate {
    let locationManager = CLLocationManager()
    @Published var location: CLLocationCoordinate2D?
    @Published var weather: String?
    
    override init(){
        super.init()
        locationManager.delegate = self
        requestLocation()
    }
    
    func requestLocation(){
//        isLoading = true
        locationManager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.first?.coordinate
        //        isLoading = false
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error getting Location", error)
//        isLoading = false
    }
    func safeCheck()->Bool{
        guard location?.latitude != nil else {
            print("a")
            return false
        }
        print(location?.latitude)
        return true
    }
    func fetchWeather() async{
        let apiKey = "0c1c75684be58fb876085111b79be4c9"
        guard let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?lat=\(location?.latitude ?? 0)&lon=\(location?.longitude ?? 0)&appid=\(apiKey)&units=metric") else {
            print("Missing URL")
            return
        }
        let urlRequest = URLRequest(url: url)
        do {
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("Error while fetching data")
                return
            }
            let decodedData = try JSONDecoder().decode(ResponseBody.self, from: data)
            DispatchQueue.main.async {
                self.weather = decodedData.weather.first?.main
                print(self.weather ?? "nil")
            }
        } catch {
            print("Error: \(error)")
        }
    }
}

struct ResponseBody: Decodable {
    var coord: CoordinatesResponse
    var weather: [WeatherResponse]
    var main: MainResponse
    var name: String
    var wind: WindResponse

    struct CoordinatesResponse: Decodable {
        var lon: Double
        var lat: Double
    }

    struct WeatherResponse: Decodable {
        var id: Double
        var main: String
        var description: String
        var icon: String
    }

    struct MainResponse: Decodable {
        var temp: Double
        var feels_like: Double
        var temp_min: Double
        var temp_max: Double
        var pressure: Double
        var humidity: Double
    }
    
    struct WindResponse: Decodable {
        var speed: Double
        var deg: Double
    }
}

extension ResponseBody.MainResponse {
    var feelsLike: Double { return feels_like }
    var tempMin: Double { return temp_min }
    var tempMax: Double { return temp_max }
}

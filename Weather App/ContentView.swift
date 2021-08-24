//
//  ContentView.swift
//  Weather App
//
//  Created by Camille Khubbetdinov on 04.09.2020.
//  Copyright © 2020 Camille Khubbetdinov. All rights reserved.
//

import SwiftUI
import CoreLocation

// MARK: - TheWeather
struct TheWeather: Codable {
    let coord: Coord
    let weather: [Weather]
    let base: String
    let main: Main
    let visibility: Int
    let wind: Wind
    let clouds: Clouds
    let dt: Double
    let sys: Sys
    let timezone, id: Int
    let name: String
    let cod: Int
}

// MARK: - Clouds
struct Clouds: Codable {
    let all: Int
}

// MARK: - Coord
struct Coord: Codable {
    let lon, lat: Double
}

// MARK: - Main
struct Main: Codable {
    let temp: Double
    var feelsLike: Double
    let tempMin, tempMax, pressure, humidity: Double

    enum CodingKeys: String, CodingKey {
        case temp
        case feelsLike = "feels_like"
        case tempMin = "temp_min"
        case tempMax = "temp_max"
        case pressure, humidity
    }
}

// MARK: - Sys
struct Sys: Codable {
    let type, id: Int
    let country: String
    let sunrise, sunset: Int
}

// MARK: - Weather
struct Weather: Codable {
    let id: Int
    let main, weatherDescription, icon: String

    enum CodingKeys: String, CodingKey {
        case id, main
        case weatherDescription = "description"
        case icon
    }
}

// MARK: - Wind
struct Wind: Codable {
    let speed, deg: Double
}


extension Double {
    func roundAndString() -> String {
        let n: Double = self
        let copy = String(n.rounded())
        if let n = copy.range(of: ".")?.lowerBound {
            return(String(copy.prefix(upTo: n)))
        } else {
            return copy
        }
    }
}


struct Cities {
    @Binding var selection: Int
    private static var cities: [String] = {
        var data: [String]? = UserDefaults.standard.stringArray(forKey: "cities")
        if data == nil {
            return []
        } else {
            return UserDefaults.standard.stringArray(forKey: "cities")!
        }
    }()
    
    static func getCitiesText() -> Array<String> {
        var copyOfCities = Cities.cities
        for i in 0..<copyOfCities.count {
            if copyOfCities[i].contains("%20") {
                copyOfCities[i] = copyOfCities[i].replacingOccurrences(of: "%20", with: " ")
            }
        }
        return copyOfCities
    }
    
    static func appendCity(newCity: String) {
        for city in self.cities {
            if city == newCity {
                return
            }
        }
        cities.append(newCity)
        UserDefaults.standard.set(self.cities, forKey: "cities")
        return
    }
    
    static func clearAll() {
        self.cities = []
        UserDefaults.standard.set(self.cities, forKey: "cities")
    }
    
    @State static var areNoCities = { return Cities.cities.isEmpty }
}



class Api {
    static var tempM = TempM.celcium
    static var windM = WindM.kmph
    static var pressureM = PressureM.mmHg
    static var lang = Lang.en
    static let api_key = "fd4048b14ce6a707ca6438b279a31f4e"
    static var lat = "-73.93"
    static var lon = "20.94"
    static var city = "Innopolis"
    static var units: String {
        get {
            switch tempM {
                case TempM.celcium: return "metric"
                case TempM.farenheit: return "imperial"
                case TempM.kelvin: return "standard"
            }
        }
        
    }
    static var requestByCity = {return "https://api.openweathermap.org/data/2.5/weather?q=\(city)&lang=\(lang)&units=\(units)&appid=\(api_key)"}
    static var requestByGeo = {return "https://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(lon)&lang=\(lang)&units=\(units)&appid=\(api_key)"}
    
    static func getWeatherByCity(completion: @escaping (TheWeather) -> ()) {
        //print("YOUR REQUEST IS \(Api.requestByCity())")
        guard let url = URL(string: Api.requestByCity()) else { return }
        URLSession.shared.dataTask(with: url) { (data, url_response, error) in
            guard let data = data else { return }
            let weather = try? JSONDecoder().decode(TheWeather.self, from: data)
            DispatchQueue.main.async {
                if weather == nil {
                    completion(TheWeather(coord: Coord(lon: 0, lat: 0), weather: [Weather(id: 0, main: "", weatherDescription: "", icon: "")], base: "", main: Main(temp: 0, feelsLike: 0, tempMin: 0, tempMax: 0, pressure: 0, humidity: 0), visibility: 0, wind: Wind(speed: 0, deg: 0), clouds: Clouds(all: 0), dt: 0, sys: Sys(type: 0, id: 0, country: "", sunrise: 0, sunset: 0), timezone: 0, id: 0, name: "Innopolis", cod: 0))
                } else {
                    completion(weather!)
                }
                group.leave()
            }
        }
        .resume()
    }
    
    static let group = DispatchGroup()
    
    static func getWeatherByGeo(completion: @escaping (TheWeather) -> ()) {
        //print("SYSTEM IS \(String(describing: units))")
        //print("YOUR REQUEST IS \(Api.requestByGeo())")
        guard let url = URL(string: Api.requestByGeo()) else { return }
        URLSession.shared.dataTask(with: url) { (data, url_response, error) in
            guard let data = data else { return }
            let weather = try? JSONDecoder().decode(TheWeather.self, from: data)
            //group.enter()
            DispatchQueue.main.async {
                if weather == nil {
                    completion(TheWeather(coord: Coord(lon: 0, lat: 0), weather: [Weather(id: 0, main: "", weatherDescription: "", icon: "")], base: "", main: Main(temp: 0, feelsLike: 0, tempMin: 0, tempMax: 0, pressure: 0, humidity: 0), visibility: 0, wind: Wind(speed: 0, deg: 0), clouds: Clouds(all: 0), dt: 0, sys: Sys(type: 0, id: 0, country: "", sunrise: 0, sunset: 0), timezone: 0, id: 0, name: "Innopolis", cod: 0))
                } else {
                    completion(weather!)
                }
                group.leave()
            }
        }
        .resume()
    }
}





struct ContentView: View {
    
    init() {
        
    }
    
    @State var weather = TheWeather(coord: Coord(lon: 0, lat: 0), weather: [Weather(id: 0, main: "", weatherDescription: "", icon: "")], base: "", main: Main(temp: 0, feelsLike: 0, tempMin: 0, tempMax: 0, pressure: 0, humidity: 0), visibility: 0, wind: Wind(speed: 0, deg: 0), clouds: Clouds(all: 0), dt: 0, sys: Sys(type: 0, id: 0, country: "", sunrise: 0, sunset: 0), timezone: 0, id: 0, name: "Innopolis", cod: 0)
    
    @State private var currentLocation = CLLocationCoordinate2D()
    @State var feelsLike: String = "0°"
    @State var temp: String = "0°"
    @State var description: String = "Clear"
    @State var place: String = "Innopolis"
    @State var windSpeed: String = "0.0"
    @State var lastUpdate: String = "Not Updated"
    //NEW ONES
    @State var tempMin: String = "0°"
    @State var tempMax: String = "0°"
    @State var pressure: String = "0"
    @State var humidity: String = "0"
    @State var visibility: String = "0"
    @State var winDeg: String = "0"
    @State var clouds: String = "0"
    @State var sunrise: String = "0"
    @State var sunset: String = "0"
    
    @State var isShowing: Bool = false
    @State var setCity: Bool = false
    @State var isSheetPresented: Bool = false
    @State var refreshNow = false
    @State var navigationBarHidden = true
    
    private func tempVisualisation(n: Double, ob: inout String) {
        if n > 0 {
            ob = "+" + n.roundAndString() + "°"
        } else if n < 0 {
            ob = n.roundAndString() + "°"
        } else {
            ob = "0°"
        }
    }
    
    private func updateVisual() {
        
        tempVisualisation(n: weather.main.feelsLike, ob: &self.feelsLike)
        tempVisualisation(n: weather.main.temp, ob: &self.temp)
        
        tempVisualisation(n: weather.main.tempMax, ob: &self.tempMax)
        tempVisualisation(n: weather.main.tempMin, ob: &self.tempMin)
        
        self.description = weather.weather[0].weatherDescription.capitalized
        self.place = weather.name
        self.windSpeed = String(weather.wind.speed)
        var date = Date(timeIntervalSince1970: weather.dt)
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = DateFormatter.Style.short //Set time style
        dateFormatter.dateStyle = DateFormatter.Style.none //Set date style
        dateFormatter.timeZone = .current
        self.lastUpdate = dateFormatter.string(from: date)
        
        self.pressure = String(weather.main.pressure)
        self.humidity = String(weather.main.humidity)
        self.visibility = String(weather.visibility)
        self.winDeg = String(weather.wind.deg)
        self.clouds = String(weather.clouds.all)
        
        date = Date(timeIntervalSince1970: TimeInterval(weather.sys.sunrise))
        self.sunrise = dateFormatter.string(from: date)
        
        date = Date(timeIntervalSince1970: TimeInterval(weather.sys.sunset))
        self.sunset = dateFormatter.string(from: date)
        
        switch weather.weather[0].id {
        case 200...232:
            self.rectangleColor = Color("Thunder")
            self.buttonColor = Color("ButtonThunder")
        
        case 300...321:
            self.rectangleColor = Color("Rain")
            self.buttonColor = Color("ButtonRain")
            
        case 500...531:
            self.rectangleColor = Color("Rain")
            self.buttonColor = Color("ButtonRain")
            
        case 600...622:
            self.rectangleColor = Color("Dust")
            self.buttonColor = Color("ButtonDust")
            
        case 701...781:
            self.rectangleColor = Color("Dust")
            self.buttonColor = Color("ButtonDust")
            
        case 801...804:
            self.rectangleColor = Color("Dust")
            self.buttonColor = Color("ButtonDust")
            
        default:
            self.rectangleColor = Color("Clear")
            self.buttonColor = Color("ButtonClear")
        
        }
    }
    
    private func defaultsUpdate(key: String, defaultValue: String) {
        if UserDefaults.standard.string(forKey: key) == nil {
            UserDefaults.standard.setValue(defaultValue, forKey: key)
        }
    }
    
    private func uploadActualSettings() {
        defaultsUpdate(key: "tempM", defaultValue: TempM.celcium.rawValue)
        defaultsUpdate(key: "windM", defaultValue: WindM.kmph.rawValue)
        defaultsUpdate(key: "pressureM", defaultValue: PressureM.mmHg.rawValue)
        defaultsUpdate(key: "lang", defaultValue: Lang.en.rawValue)
        Api.tempM = TempM(rawValue: UserDefaults.standard.string(forKey: "tempM")!)!
        Api.windM = WindM(rawValue: UserDefaults.standard.string(forKey: "windM")!)!
        Api.pressureM = PressureM(rawValue: UserDefaults.standard.string(forKey: "pressureM")!)!
        Api.lang = Lang(rawValue: UserDefaults.standard.string(forKey: "lang")!)!
    }
    
    private func refreshData() {
        //print("NOW ITS \(self.setCity)")
        //print("THE CITY IS \(Api.city)")
        uploadActualSettings()
        if self.setCity {
            refreshDataCity()
        } else {
            refreshDataGeo()
        }
        self.setCity = false
        print(self.weather)
        print()
    }
    
    private func refreshDataGeo() {
        Api.lat = self.userLatitude //выставляем гео 1
        Api.lon = self.userLongitude //выставляем гео 2
        //print("THE LOCATION IS " + self.userLatitude + " " + self.userLatitude)
        Api.getWeatherByGeo(completion: {(neww) in //забираем neww — это актуальная погода
            self.weather = neww //теперь наша погода актуальная
            //print("WE HAVE TO HAVE \(self.weather.weather[0].weatherDescription)") //да, всё обновилось!
        })
        Api.group.enter()
        Api.group.notify(queue: .main) {
            self.updateVisual() //перезаписываем @State переменные
        }
        do {
            try UserDefaults.standard.setObject(self.weather, forKey: "weather")
        } catch {
            print(error.localizedDescription)
        }
        Cities.appendCity(newCity: weather.name)
    }
    
    private func refreshDataCity() {
        //Api.lat = self.userLatitude //выставляем гео 1
        //Api.lon = self.userLongitude //выставляем гео 2
        //print("THE LOCATION IS " + self.userLatitude + " " + self.userLatitude)
        Api.getWeatherByCity(completion: {(neww) in //забираем neww — это актуальная погода
            self.weather = neww //теперь наша погода актуальная
        })
        Api.group.enter()
        Api.group.notify(queue: .main) {
            self.updateVisual() //перезаписываем @State переменные
        }
        do {
            try UserDefaults.standard.setObject(self.weather, forKey: "weather")
        } catch {
            print(error.localizedDescription)
        }
        //Cities.appendCity(newCity: weather.name)
    }
    
    
    
    @ObservedObject var locationManager = LocationManager()

    var userLatitude: String {
        return "\(locationManager.lastLocation?.coordinate.latitude ?? 0)"
    }

    var userLongitude: String {
        return "\(locationManager.lastLocation?.coordinate.longitude ?? 0)"
    }
    
    @State var rectangleColor: Color = Color("Clear")
    @State var buttonColor: Color = Color("ButtonClear")
    var body: some View {
        NavigationView {
            ZStack {
                Rectangle()
                    .foregroundColor(Color("Opacity"))
                    .background(LinearGradient(gradient: Gradient(colors: [self.rectangleColor, Color("Background")]), startPoint: .top, endPoint: .bottom))
                    .edgesIgnoringSafeArea(.all)
                
                CurrentWeatherSmall(feelsLike: self.$feelsLike, temp: self.$temp, description: self.$description, place: self.$place, windSpeed: self.$windSpeed, setCity: self.$setCity, weather: self.$weather, lastUpdate: self.$lastUpdate, tempMin: self.$tempMin, tempMax: self.$tempMax, pressure: self.$pressure, humidity: self.$humidity, visibility: self.$visibility, winDeg: self.$winDeg, clouds: self.$clouds, sunrise: self.$sunrise, sunset: self.$sunset, isSheetPresented: self.$isSheetPresented, navBarHidden: self.$navigationBarHidden, buttonColor: self.$buttonColor, rectangleColor: self.$rectangleColor)
                    .navigationBarTitle("Weather")
                    .navigationBarHidden(self.navigationBarHidden)
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                if UserDefaults.standard.string(forKey: "weather") != nil {
                    //self.weather = UserDefaults.standard.dictionary(forKey: "weather")
                    do {
                        try self.weather = UserDefaults.standard.getObject(forKey: "weather", castTo: TheWeather.self)
                    } catch {
                        print(error.localizedDescription)
                    }
                    self.refreshData()
                } else {
                    self.refreshData()
                }
            }
            .onAppear() {
                if UserDefaults.standard.string(forKey: "weather") != nil {
                    //self.weather = UserDefaults.standard.dictionary(forKey: "weather")
                    do {
                        try self.weather = UserDefaults.standard.getObject(forKey: "weather", castTo: TheWeather.self)
                    } catch {
                        print(error.localizedDescription)
                    }
                    self.refreshData()
                } else {
                    self.refreshData()
                }
            }
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

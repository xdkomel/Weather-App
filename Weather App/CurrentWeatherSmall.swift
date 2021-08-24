//
//  CurrentWeatherSmall.swift
//  Weather App
//
//  Created by Camille Khubbetdinov on 06.09.2020.
//  Copyright © 2020 Camille Khubbetdinov. All rights reserved.
//

import SwiftUI

extension UIScreen {
    static let screenWidth = UIScreen.main.bounds.size.width
    static let screenHeight = UIScreen.main.bounds.size.height
}

struct CurrentWeatherSmall: View {
    @Binding var feelsLike: String
    @Binding var temp: String
    @Binding var description: String
    @Binding var place: String
    @Binding var windSpeed: String
    @Binding var setCity: Bool
    @Binding var weather: TheWeather
    @Binding var lastUpdate: String
    
    @Binding var tempMin: String
    @Binding var tempMax: String
    @Binding var pressure: String
    @Binding var humidity: String
    @Binding var visibility: String
    @Binding var winDeg: String
    @Binding var clouds: String
    @Binding var sunrise: String
    @Binding var sunset: String
    
    @Binding var isSheetPresented: Bool
    @State var isSettingsOpened: Bool = false
    @Binding var navBarHidden: Bool
    
    @State var tempM: TempM = TempM.celcium //по-умолчанию фаренгейт
    @State var windM: WindM = WindM.kmph
    @State var pressureM: PressureM = PressureM.mmHg
    @State var lang: Lang = Lang.en
    
    @Binding var buttonColor: Color
    @Binding var rectangleColor: Color
    
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
        tempM = TempM(rawValue: UserDefaults.standard.string(forKey: "tempM")!)!
        windM = WindM(rawValue: UserDefaults.standard.string(forKey: "windM")!)!
        pressureM = PressureM(rawValue: UserDefaults.standard.string(forKey: "pressureM")!)!
        lang = Lang(rawValue: UserDefaults.standard.string(forKey: "lang")!)!
    }
    
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
//        if weather.main.feelsLike > 0 {
//            self.feelsLike = "+" + weather.main.feelsLike.roundAndString() + "°"
//        } else {
//            self.feelsLike = weather.main.feelsLike.roundAndString() + "°"
//        }
        
        tempVisualisation(n: weather.main.temp, ob: &self.temp)
//        if weather.main.temp > 0 {
//            self.temp = "+" + String(weather.main.temp.roundAndString()) + "°"
//        } else {
//            self.temp = String(weather.main.temp.roundAndString()) + "°"
//        }
        
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
    
    private func updateNow() {
        Api.getWeatherByCity { (newWeather) in
            self.weather = newWeather
        }
        Api.group.enter()
        Api.group.notify(queue: .main) {
            self.updateVisual() //перезаписываем @State переменные
        }
        do {
            try UserDefaults.standard.setObject(self.weather, forKey: "weather")
        } catch {
            print(error.localizedDescription)
        }
    }
    
    var body: some View {
        VStack {
            HStack {
                Text(self.place)
                    .padding()
                    .lineLimit(1)
                    .foregroundColor(self.buttonColor)
                    .contextMenu(menuItems: {
                        ForEach(Cities.getCitiesText(), id:\.self) { city in
                            Button(city) {
                                Api.city = city
                                setCity = true
                                updateNow()
                            }
                        }
                    })
                    .onTapGesture {
                        
                        self.isSheetPresented.toggle()
                    }
                    .sheet(isPresented: self.$isSheetPresented) {
                        CitiesView(isShowing: self.$isSheetPresented, setCity: self.$setCity, weather: self.$weather, feelsLike: self.$feelsLike, temp: self.$temp, description: self.$description, place: self.$place, windSpeed: self.$windSpeed, buttonColor: self.$buttonColor, rectangleColor: self.$rectangleColor)
                    }
                Spacer()
                Text("Settings")
                    .padding()
                    .foregroundColor(self.buttonColor)
                    .onTapGesture(count: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/, perform: {
                        uploadActualSettings()
                        self.isSettingsOpened.toggle()
                    })
                    .sheet(isPresented: self.$isSettingsOpened, content: {
                        SettingsView(isOpened: self.$isSettingsOpened, tempM: self.$tempM, windM: self.$windM, pressureM: self.$pressureM, lang: self.$lang, weather: self.$weather, feelsLike: self.$feelsLike, temp: self.$temp, description: self.$description, place: self.$place, windSpeed: self.$windSpeed, buttonColor: self.$buttonColor, rectangleColor: self.$rectangleColor)
                    })
            }
            Spacer()
            Text(self.description)
                .foregroundColor(Color("TextColor"))
            Text(self.feelsLike)
                .font(Font(UIFont(name: "SFRoundedSemibold", size: 80)!))
                .multilineTextAlignment(.center)
                .foregroundColor(Color("TextColor"))
            Text("Air Temperature \(self.temp)")
                .foregroundColor(Color("TextColor"))
            Spacer()
            HStack {
                HStack {
                    Image(systemName: "wind")
                        .foregroundColor(Color("TextColor"))
                    Text("\(self.windSpeed) \(Api.windM.rawValue)")
                        .foregroundColor(Color("TextColor"))
                }.padding()
                
                Spacer()
                NavigationLink(destination: FullWeatherView(description: self.$description, place: self.$place, feelsLike: self.$feelsLike, temp: self.$temp, tempMin: self.$tempMin, tempMax: self.$tempMax, pressure: self.$pressure, humidity: self.$humidity, visibility: self.$visibility, windSpeed: self.$windSpeed, windDeg: self.$winDeg, clouds: self.$clouds, sunrise: self.$sunrise, sunset: self.$sunset, lastUpdate: self.$lastUpdate)) {
                    Text("See All")
                        .padding()
                        .foregroundColor(self.buttonColor)
                }
                
            }
        }
    }
}

//struct CurrentWeatherSmall_Previews: PreviewProvider {
//    static var previews: some View {
//        CurrentWeatherSmall(feelsLike: .constant("+20°"), temp: .constant("+19°"), description: .constant("Clear Sky"), place: .constant("Kazan"), windSpeed: .constant("1.0 m/s"), setCity: .constant(false), weather: .constant(TheWeather(coord: Coord(lon: 0, lat: 0), weather: [Weather(id: 0, main: "", weatherDescription: "", icon: "")], base: "", main: Main(temp: 0, feelsLike: 0, tempMin: 0, tempMax: 0, pressure: 0, humidity: 0), visibility: 0, wind: Wind(speed: 0, deg: 0), clouds: Clouds(all: 0), dt: 0, sys: Sys(type: 0, id: 0, country: "", sunrise: 0, sunset: 0), timezone: 0, id: 0, name: "Innopolis", cod: 0)), lastUpdate: .constant(""), tempMin: .constant("0"), tempMax: .constant("0"), tempMin: .constant(" "), isSheetPresented: .constant(false), navBarHidden: .constant(true))
//            .previewLayout(.sizeThatFits)
//    }
//}

struct CurrentWeatherSmall_Previews: PreviewProvider {
    static var previews: some View {
        CurrentWeatherSmall(feelsLike: .constant("a"), temp: .constant("a"), description: .constant("a"), place: .constant("a"), windSpeed: .constant("a"), setCity: .constant(true), weather: .constant(TheWeather(coord: Coord(lon: 0, lat: 0), weather: [Weather(id: 0, main: "", weatherDescription: "", icon: "")], base: "", main: Main(temp: 0, feelsLike: 0, tempMin: 0, tempMax: 0, pressure: 0, humidity: 0), visibility: 0, wind: Wind(speed: 0, deg: 0), clouds: Clouds(all: 0), dt: 0, sys: Sys(type: 0, id: 0, country: "", sunrise: 0, sunset: 0), timezone: 0, id: 0, name: "Innopolis", cod: 0)), lastUpdate: .constant("a"), tempMin: .constant("a"), tempMax: .constant("a"), pressure: .constant("a"), humidity: .constant("a"), visibility: .constant("a"), winDeg: .constant("a"), clouds: .constant("a"), sunrise: .constant("a"), sunset: .constant("a"), isSheetPresented: .constant(true), isSettingsOpened: true, navBarHidden: .constant(true), tempM: TempM.celcium, windM: WindM.kmph, pressureM: PressureM.mmHg, lang: Lang.en, buttonColor: .constant(Color(.blue)), rectangleColor: .constant(Color(.black)))
    }
}

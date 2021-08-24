//
//  SettingsView.swift
//  Weather App
//
//  Created by Camille Khubbetdinov on 08.11.2020.
//  Copyright © 2020 Camille Khubbetdinov. All rights reserved.
//

import SwiftUI

public enum TempM: String, CaseIterable, Codable {
    case celcium = "°C"
    case farenheit = "°F"
    case kelvin = "°K"
}
public enum WindM: String, CaseIterable, Codable {
    case mps
    case kmph
}
public enum PressureM: String, CaseIterable, Codable {
    case mmHg
    case hPa
}
public enum Lang: String, CaseIterable, Codable {
    case en
    case ru
}



struct SettingsView: View {
    @Binding var isOpened: Bool
    
    @Binding var tempM: TempM
    @Binding var windM: WindM
    @Binding var pressureM: PressureM
    @Binding var lang: Lang
    
    @Binding var weather: TheWeather
    @Binding var feelsLike: String
    @Binding var temp: String
    @Binding var description: String
    @Binding var place: String
    @Binding var windSpeed: String
    
    @Binding var buttonColor: Color
    @Binding var rectangleColor: Color
    
    @State var closeButtonText: String = "Close"
    
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
        
        self.description = weather.weather[0].weatherDescription.capitalized
        self.place = weather.name
        self.windSpeed = String(weather.wind.speed)
        
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
    

    private func saveSettings() {
        Api.tempM = self.tempM
        Api.windM = self.windM
        Api.pressureM = self.pressureM
        Api.lang = self.lang
        UserDefaults.standard.setValue(tempM.rawValue, forKey: "tempM")
        UserDefaults.standard.setValue(windM.rawValue, forKey: "windM")
        UserDefaults.standard.setValue(pressureM.rawValue, forKey: "pressureM")
        UserDefaults.standard.setValue(lang.rawValue, forKey: "lang")
    }
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Text("Temperature").padding()
                    Spacer()
                    Picker(selection: self.$tempM, label: Text("Temperature")) /*@START_MENU_TOKEN@*/{
                        ForEach(TempM.allCases, id: \.self) { i in
                            Text(i.rawValue)
                        }
                    }
                        .frame(width: 140)
                        .pickerStyle(SegmentedPickerStyle())
                        .padding()
                        .onChange(of: tempM, perform: { value in
                            self.closeButtonText = "Close and Save"
                        })
                }
                HStack {
                    Text("Wind Speed").padding()
                    Spacer()
                    Picker(selection: self.$windM, label: Text("Wind Speed")) /*@START_MENU_TOKEN@*/{
                        ForEach(WindM.allCases, id: \.self) { i in
                            Text(i.rawValue)
                        }
                    }
                        .frame(width: 140)
                        .pickerStyle(SegmentedPickerStyle())
                        .padding()
                        .onChange(of: windM, perform: { value in
                            self.closeButtonText = "Close and Save"
                        })
                }
                HStack {
                    Text("Pressure").padding()
                    Spacer()
                    Picker(selection: self.$pressureM, label: Text("Pressure")) /*@START_MENU_TOKEN@*/{
                        ForEach(PressureM.allCases, id: \.self) { i in
                            Text(i.rawValue)
                        }
                    }
                        .frame(width: 140)
                        .pickerStyle(SegmentedPickerStyle())
                        .padding()
                        .onChange(of: windM, perform: { value in
                            self.closeButtonText = "Close and Save"
                        })
                }
                HStack {
                    Text("Language").padding()
                    Spacer()
                    Picker(selection: self.$lang, label: Text("Language")) /*@START_MENU_TOKEN@*/{
                        ForEach(Lang.allCases, id: \.self) { i in
                            Text(i.rawValue)
                        }
                    }
                        .frame(width: 140)
                        .pickerStyle(SegmentedPickerStyle())
                        .padding()
                        .onChange(of: windM, perform: { value in
                            self.closeButtonText = "Close and Save"
                        })
                }
                
            }
            .navigationBarTitle("Settings")
            .navigationBarItems(leading: Button(self.closeButtonText) {
                saveSettings()
                updateNow()
                self.isOpened.toggle()
            })
                
        }
        
            
    }
}

//struct SettingsView_Previews: PreviewProvider {
//    static var previews: some View {
//        SettingsView(isOpened: .constant(true), tempM: .constant(TempM.celcium), windM: .constant(WindM.kmph), pressureM: .constant(PressureM.mmHg), lang: .constant(Lang.en))
//    }
//}

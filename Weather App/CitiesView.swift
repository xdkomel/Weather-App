//
//  CitiesView.swift
//  Weather App
//
//  Created by Camille Khubbetdinov on 12.09.2020.
//  Copyright © 2020 Camille Khubbetdinov. All rights reserved.
//

import SwiftUI

struct SearchBar: UIViewRepresentable {

    @Binding var text: String

    class Coordinator: NSObject, UISearchBarDelegate {
        @Binding var text: String

        init(text: Binding<String>) {
            _text = text
        }

        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            text = searchText
        }
        
        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            UIApplication.shared.endEditing()
        }
    }
    
    func makeCoordinator() -> SearchBar.Coordinator {
        return Coordinator(text: $text)
    }

    func makeUIView(context: UIViewRepresentableContext<SearchBar>) -> UISearchBar {
        let searchBar = UISearchBar(frame: .zero)
        searchBar.delegate = context.coordinator
        searchBar.autocapitalizationType = .none
        searchBar.autocorrectionType = .no
        searchBar.placeholder = "Search"
        return searchBar
    }

    func updateUIView(_ uiView: UISearchBar, context: UIViewRepresentableContext<SearchBar>) {
        uiView.text = text
    }
}

extension String {
    func containsCaseInsensitive(_ string: String) -> Bool {
        return self.localizedCaseInsensitiveContains(string)
    }
}

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct CitiesView: View {
    
    @Binding var isShowing: Bool
    @Binding var setCity: Bool
    
    @Binding var weather: TheWeather
    @Binding var feelsLike: String
    @Binding var temp: String
    @Binding var description: String
    @Binding var place: String
    @Binding var windSpeed: String
    
    @Binding var buttonColor: Color
    @Binding var rectangleColor: Color
    
    @State var aButtonBackground: Color = .white
    
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
    
    var body: some View {
        
        if Cities.areNoCities() {
            NavigationView {
                Text("Seem you have no saved cities")
                    .padding()
                    .font(.largeTitle)
                    .opacity(0.5)
                //.navigationTitle("Your cities")
                //.navigationBarTitleDisplayMode(.large)
                    .multilineTextAlignment(.center)
                    .navigationBarItems(leading: Button("Close") {
                        isShowing.toggle()
                    })
                    
            }
        } else {
            NavigationView {
                ScrollView {
                    VStack {
                        SearchBar(text: .constant(""))
                        ForEach(Cities.getCitiesText(), id:\.self) { city in
                            ZStack {
                                Rectangle().foregroundColor(self.aButtonBackground)
                                VStack {
                                    HStack {
                                        Text(city)
                                            .padding(.horizontal, 8)
                                            .padding(.top, 4)
                                        Spacer()
                                        Image(systemName: "chevron.forward")
                                            .padding(.horizontal, 8)
                                            .padding(.top, 4)
                                    }
                                        .buttonStyle(PlainButtonStyle())
                                    Divider()
                                }
                            }
                                .onTapGesture() {
                                    
                                    Api.city = city
                                    setCity = true
                                    updateNow()
                                    isShowing.toggle()
                                }
                        }
                        
                    }
                    
                }
                    .navigationTitle("Your cities")
                    .navigationBarTitleDisplayMode(.large)
                    .navigationBarItems(leading: Button("Close") {
                        isShowing.toggle()
                    }, trailing: Button("Clear") {
                        Cities.clearAll()
                        isShowing.toggle()
                    })
                
            }
            
            
        }
    }
}

struct CitiesView_Previews: PreviewProvider {
    static var previews: some View {
        CitiesView(isShowing: .constant(true), setCity: .constant(false), weather: .constant(TheWeather(coord: Coord(lon: 0, lat: 0), weather: [Weather(id: 0, main: "", weatherDescription: "", icon: "")], base: "", main: Main(temp: 0, feelsLike: 0, tempMin: 0, tempMax: 0, pressure: 0, humidity: 0), visibility: 0, wind: Wind(speed: 0, deg: 0), clouds: Clouds(all: 0), dt: 0, sys: Sys(type: 0, id: 0, country: "", sunrise: 0, sunset: 0), timezone: 0, id: 0, name: "Innopolis", cod: 0)), feelsLike: .constant("0"), temp: .constant("0"), description: .constant("nothin"), place: .constant("Innopolis"), windSpeed: .constant("0"), buttonColor: .constant(Color.blue), rectangleColor: .constant(Color.blue))
    }
}

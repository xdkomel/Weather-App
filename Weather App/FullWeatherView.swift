//
//  FullWeatherView.swift
//  Weather App
//
//  Created by Camille Khubbetdinov on 12.11.2020.
//  Copyright © 2020 Camille Khubbetdinov. All rights reserved.
//

import SwiftUI

struct FullWeatherView: View {
    
    @Binding var description: String
    @Binding var place: String
    @Binding var feelsLike: String
    @Binding var temp: String
    
    @Binding var tempMin: String
    @Binding var tempMax: String
    
    @Binding var pressure: String
    @Binding var humidity: String
    @Binding var visibility: String
    @Binding var windSpeed: String
    @Binding var windDeg: String
    @Binding var clouds: String
    @Binding var sunrise: String
    @Binding var sunset: String
    @Binding var lastUpdate: String
    
    
    var body: some View {
         //ScrollView {
            Form {
                //Spacer()
                Section(header: Text("Current Weather")) {
                    Text(self.description)
                        .frame(width: UIScreen.screenWidth-64)
                        .multilineTextAlignment(.center)
                    Text(self.feelsLike)
                        .frame(width: UIScreen.screenWidth-64)
                        .font(Font(UIFont(name: "SFRoundedSemibold", size: 80)!))
                        .multilineTextAlignment(.center)
                    Text("Air Temperature \(self.temp)")
                        .frame(width: UIScreen.screenWidth-64)
                        .multilineTextAlignment(.center)
                }
                Section(header: Text("Temperature Variation")) {
                    ZStack {
                        GeometryReader { gr in
                            Path { path in
                                path.move(to: CGPoint(x: 4, y: 4))
                                path.addLine(to: CGPoint(x: gr.size.width-4, y: 37))
                            }
                                .stroke(Color.blue, lineWidth: 2)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        HStack(alignment: .top) {
                            VStack(alignment: .leading) {
                                Ellipse()
                                    .frame(width: 8, height: 8)
                                    .foregroundColor(Color.blue)
                                Text(self.tempMax)
                            }
                            Spacer()
                            VStack(alignment: .trailing) {
                                Text(self.tempMin)
                                Ellipse()
                                    .frame(width: 8, height: 8)
                                    .foregroundColor(Color.blue)
                            }
                        }
                        
                    }.padding(.vertical, 8)
                }
                Section {
                    Group {
                        HStack {
                            Image(systemName: "wind").frame(width: 16)
                            Text("Wind Speed")
                            Spacer()
                            Text("\(self.windSpeed) \(Api.windM.rawValue)")
                        }.frame(alignment: .leading)
                        HStack {
                            Image(systemName: "safari").frame(width: 16)
                            Text("Wind Degree")
                            Spacer()
                            Text("\(self.windDeg)")
                        }.frame(alignment: .leading)
                    }
                    Group {
                        HStack {
                            Image(systemName: "barometer").frame(width: 16)
                            Text("Pressure")
                            Spacer()
                            Text("\(self.pressure)")
                        }.frame(alignment: .leading)
                        HStack {
                            Image(systemName: "drop").frame(width: 16)
                            Text("Humidity")
                            Spacer()
                            Text("\(self.humidity)")
                        }.frame(alignment: .leading)
                        HStack {
                            Image(systemName: "eye").frame(width: 16)
                            Text("Visibility")
                            Spacer()
                            Text("\(self.visibility)")
                        }.frame(alignment: .leading)
                        HStack {
                            Image(systemName: "cloud").frame(width: 16)
                            Text("Cloudness")
                            Spacer()
                            Text("\(self.clouds)")
                        }.frame(alignment: .leading)
                    }
                }
                Section {
                    HStack {
                        HStack {
                            Image(systemName: "sunrise").frame(width: 16)
                            Text("\(self.sunrise)")
                        }
                        Spacer()
                        HStack {
                            Text("\(self.sunset)")
                            Image(systemName: "sunset").frame(width: 16)
                        }
                    }
                }
                Section {
                    HStack {
                        Spacer()
                        Text("Last Updated at \(self.lastUpdate)")
                        Spacer()
                    }
                    
                }
                
                //Spacer()
                
            }
            
            
         .navigationBarTitle(self.place, displayMode: .large)
    }
}

struct FullWeatherView_Previews: PreviewProvider {
    static var previews: some View {
        FullWeatherView(description: .constant("a"), place: .constant("a"), feelsLike: .constant("a"), temp: .constant("a"), tempMin: .constant("aaa"), tempMax: .constant("aa"), pressure: .constant("a"), humidity: .constant("a"), visibility: .constant("a"), windSpeed: .constant("a"), windDeg: .constant("a"), clouds: .constant("a"), sunrise: .constant("a"), sunset: .constant("a"), lastUpdate: .constant("a"))
            .previewDevice("iPhone 12 Pro Max")
    }
}

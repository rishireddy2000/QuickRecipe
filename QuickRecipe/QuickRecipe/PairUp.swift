//
//  PairUp.swift
//  MixnMatch
//
//  Created by Prudhvi Puli on 3/4/24.
//

import SwiftUI

struct ActivityIndicatorView: UIViewRepresentable {
    let style: UIActivityIndicatorView.Style

    func makeUIView(context: Context) -> UIActivityIndicatorView {
        let activityIndicatorView = UIActivityIndicatorView(style: style)
        activityIndicatorView.startAnimating()
        return activityIndicatorView
    }

    func updateUIView(_ uiView: UIActivityIndicatorView, context: Context) {
    }
}

enum DisplayMode {
    case basedOnWeather, showAll
}

/// A view for pairing up top and bottom wear based on weather or showing all available combinations.
struct PairUpView: View {
    
    /// Loads an image from the document directory.
    /// - Parameter imageName: The name of the image file.
    /// - Returns: The loaded image, or nil if loading fails.
    private func loadImage(named imageName: String) -> UIImage? {
        guard let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        let fileURL = dir.appendingPathComponent(imageName)
        return UIImage(contentsOfFile: fileURL.path)
    }
    
    @ObservedObject var viewModel: FavoritesViewModel
    @Binding var wardrobeItems: [WardrobeItem]
    
    @State var currentTemperature: Double? = nil
    var weatherManager = WeatherManager()

    @State var showAlert = false
    @State var alertMessage = ""

    @State private var isFetchingData: Bool = false
//    @State private var networkshowAlert: Bool = false
//    @State private var networkalertMessage: String = ""
    @State private var isFetchingWeather: Bool = false
    
    private func fetchWeatherData() {
        isFetchingData = true
        isFetchingWeather = true
        
        weatherManager.fetchWeather(cityName: "Chicago") { result in
            DispatchQueue.main.async {
                isFetchingData = false
                isFetchingWeather = false
                
                switch result {
                case .success(let weatherModel):
                    self.currentTemperature = weatherModel.temp
                case .failure:
                    self.showAlert = true
                    self.alertMessage = "Unable to fetch weather data. Check your connection.You can only use Show All without network connection."
                }
            }
        }
    }

    @State private var displayMode: DisplayMode = .basedOnWeather
    @State var selectedTopWearIndex = 0
    @State var selectedBottomWearIndex = 0
    /// Filters top wear items based on the display mode and current temperature.
    private var topWearItems: [WardrobeItem] {
        switch displayMode {
             case .basedOnWeather:
                 guard let temperature = currentTemperature else { return [] }
                 return wardrobeItems.filter {
                     switch $0.subtype {
                     case .sweater:
                         return temperature <= 20
                     case .tshirt:
                         return temperature > 20
                     default:
                         return true
                     }
                 }.filter { $0.type == .topWear }
             case .showAll:
                 return wardrobeItems.filter { $0.type == .topWear }
         }
    }
    
    /// Filters bottom wear items based on the display mode and current temperature.
    private var bottomWearItems: [WardrobeItem] {
        switch displayMode {
            case .basedOnWeather:
                guard let temperature = currentTemperature else { return [] }
                return wardrobeItems.filter {
                    switch $0.subtype {
                    case .jeans, .trousers:
                        return true
                    case .shorts:
                        return temperature > 20
                    default:
                        return true
                    }
                }.filter { $0.type == .bottomWear }
            case .showAll:
                return wardrobeItems.filter { $0.type == .bottomWear }
        }
    }

    
    var body: some View {
            VStack {
                
                Picker("Mode", selection: $displayMode) {
                              Text("Based on Weather").tag(DisplayMode.basedOnWeather)
                              Text("Show All").tag(DisplayMode.showAll)
                  }
                  .pickerStyle(SegmentedPickerStyle())
                  .padding()

                if displayMode == .basedOnWeather{
                    if let temperature = currentTemperature {
                        Text("Current Temperature: \(temperature, specifier: "%.1f")°C")
                            .font(.headline)
                            .padding(.vertical,5)
                    } else {
                        Text("Fetching temperature...")
                            .font(.headline)
                            .padding(.vertical,5)
                    }
                }

                
                Text("Top Wear")
                    .font(.headline)
                TabView(selection: $selectedTopWearIndex) {
                    ForEach(topWearItems.indices, id: \.self) { index in
                        VStack {
                            if let uiImage = loadImage(named: topWearItems[index].imageName) {
                               Image(uiImage: uiImage)
                                   .resizable()
                                   .scaledToFit()
                                   .tag(index)
                           } else {
                               Image(systemName: "photo")
                                   .resizable()
                                   .scaledToFit()
                                   .frame(width: 200, height: 200)
                                   .tag(index)
                           }
                            Text(topWearItems[index].name) // Optional: Show name
                        }
                    }
                }
                .frame(height: 180)
                .tabViewStyle(PageTabViewStyle())
                .padding()
                
                navigationButtons(count: topWearItems.count, selectedIndex: $selectedTopWearIndex)
                
                Text("Bottom Wear")
                    .font(.headline)
                TabView(selection: $selectedBottomWearIndex) {
                    ForEach(bottomWearItems.indices, id: \.self) { index in
                        VStack {
                            if let uiImage = loadImage(named: bottomWearItems[index].imageName) {
                               Image(uiImage: uiImage)
                                   .resizable()
                                   .scaledToFit()
                                   .tag(index)
                           } else {
                               Image(systemName: "photo")
                                   .resizable()
                                   .scaledToFit()
                                   .frame(width: 200, height: 200)
                                   .tag(index)
                           }
                            Text(bottomWearItems[index].name) // Optional: Show name
                        }
                    }
                }
                .frame(height: 180)
                .tabViewStyle(PageTabViewStyle())
                .padding()
                
                navigationButtons(count: bottomWearItems.count, selectedIndex: $selectedBottomWearIndex)
                
                Button("Add to Favorites") {
                    let topWear = topWearItems.indices.contains(selectedTopWearIndex) ? topWearItems[selectedTopWearIndex] : nil
                    let bottomWear = bottomWearItems.indices.contains(selectedBottomWearIndex) ? bottomWearItems[selectedBottomWearIndex] : nil
                    addToFavorites(topWear: topWear, bottomWear: bottomWear)
                }
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                }

                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .padding()
            .onAppear{
                fetchWeatherData()
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Alert"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
            .overlay(
                Group {
                    if isFetchingWeather {
                        VStack {
                            ActivityIndicatorView(style: .large)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.5))
                        .edgesIgnoringSafeArea(.all)
                    }
                }
            )

    }
    
    
    func addToFavorites(topWear: WardrobeItem?, bottomWear: WardrobeItem?) {
        print("Adding to favorites")
        guard let topWear = topWear, let bottomWear = bottomWear else {
            if topWearItems.isEmpty && bottomWearItems.isEmpty{
                alertMessage = "Both top wear and bottom wear are missing. Please add some clothing before you proceed."
            } else if bottomWearItems.isEmpty {
                alertMessage = "There is no bottom wear available. Please add some clothing before you proceed."
            } else {
                alertMessage = "There is no top wear available. Please add some clothing before you proceed."
            }
            showAlert = true
            return
        }
        
        // Create a WardrobePair from the selected top and bottom wear
        let favoritePair = WardrobePair(topWear: topWear, bottomWear: bottomWear)
        
        // Check if this pair already exists in the favoritesArray to prevent duplicates
        if !viewModel.favoritesArray.contains(where: { $0.topWear.id == favoritePair.topWear.id && $0.bottomWear.id == favoritePair.bottomWear.id }) {
            viewModel.favoritesArray.append(favoritePair)
            viewModel.saveFavorites()
        }
    }


    
    @ViewBuilder
    func navigationButtons(count: Int, selectedIndex: Binding<Int>) -> some View {
        HStack {
            Button(action: {
                if selectedIndex.wrappedValue > 0 {
                    selectedIndex.wrappedValue -= 1
                }
            }) {
                Image(systemName: "arrow.left")
            }
            .disabled(selectedIndex.wrappedValue <= 0)
            
            Spacer()
            
            Button(action: {
                if selectedIndex.wrappedValue < count - 1 {
                    selectedIndex.wrappedValue += 1
                }
            }) {
                Image(systemName: "arrow.right")
            }
            .disabled(selectedIndex.wrappedValue >= count - 1)
        }
    }
}

struct PairUpView_Previews: PreviewProvider {
    static var previews: some View {
        // Example for preview purpose
        PairUpView(viewModel: FavoritesViewModel(), wardrobeItems: .constant([]))
    }
}

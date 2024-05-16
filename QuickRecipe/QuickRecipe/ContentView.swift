//
//  ContentView.swift
//  MixnMatch
//
//  Created by Prudhvi Puli on 3/4/24.
//

import SwiftUI
import UIKit

/// Represents an item in the wardrobe, including its name, image name, type, and subtype.
struct WardrobeItem: Identifiable, Equatable, Hashable, Codable {
    let id = UUID()
    let name: String
    var imageName: String
    let type: WardrobeItemType
    let subtype: WardrobeItemSubtype
    
    enum CodingKeys: String, CodingKey {
        case id, name, imageName, type, subtype
    }
}

/// Enum representing the type of wardrobe item, such as top wear or bottom wear.
enum WardrobeItemType: String, CaseIterable, Codable {
    case topWear = "TopWear"
    case bottomWear = "BottomWear"
}

/// Enum representing the subtype of wardrobe item, such as shirt, sweater, etc.
enum WardrobeItemSubtype: String, CaseIterable, Codable {
    case shirt = "Shirt", sweater = "Sweater", tshirt = "TShirt"
    case jeans = "Jeans", shorts = "Shorts", trousers = "Trousers"
    
    /// Returns the subtypes corresponding to the given wardrobe item type.
    static func subtypes(for type: WardrobeItemType) -> [WardrobeItemSubtype] {
        switch type {
        case .topWear:
            return [.shirt, .sweater, .tshirt]
        case .bottomWear:
            return [.jeans, .shorts, .trousers]
        }
    }
}


/// The main content view of the application
struct ContentView: View {
    @StateObject private var favoritesViewModel = FavoritesViewModel()
    @State private var selectedType: WardrobeItemType = .topWear
    @State private var showActionSheet = false
    @State private var showImagePicker: Bool = false
    @State private var sourceType: UIImagePickerController.SourceType = .camera
    @State private var image: UIImage?
    @State private var pickedImage: UIImage?
    @State private var navigateToItemDetailView = false
    @State private var selectedWardrobeItem: WardrobeItem? = nil
    @State private var lastPickedImage: UIImage?
    @State private var isEditMode: Bool = false
    @State private var wardrobeItems: [WardrobeItem] = []
    @State private var showingRatePrompt = false
    @State private var initialLaunchDate: Date?
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        // Main navigation view containing the wardrobe items
        NavigationView {
            VStack {
                // Title of the wardrobe section
                Text("Your Wardrobe").font(.largeTitle).foregroundColor(Color.white).padding()
                
                    .onAppear(perform: {
                        // Show rate prompt after three launches
                        let launchCount = updateLaunchCount()
                        if launchCount == 3 {
                            showingRatePrompt = true
                        }
                    })
                    .alert(isPresented: $showingRatePrompt) {
                        Alert(
                            title: Text("Enjoying the App?"),
                            message: Text("Rate us in the App Store!"),
                            primaryButton: .default(Text("Rate Now"), action: openAppStoreForRating),
                            secondaryButton: .cancel()
                        )
                    }
                // Buttons for selecting wardrobe item type
                HStack {
                    Button("TopWear") { selectedType = .topWear }
                        .padding().background(selectedType == .topWear ? Color.white.opacity(0.2) : Color.clear).cornerRadius(10).foregroundColor(.white)
                    
                    Button("BottomWear") { selectedType = .bottomWear }
                        .padding().background(selectedType == .bottomWear ? Color.white.opacity(0.2) : Color.clear).cornerRadius(10).foregroundColor(.white)
                }.padding()
                
                // ScrollView for displaying wardrobe items
                ScrollView {
                    VStack {
                        // Display top wear items
                        if selectedType == .topWear {
                            ForEach(WardrobeItemSubtype.subtypes(for: .topWear), id: \.self) { subtype in
                                let itemsCount = wardrobeItems.filter { $0.type == .topWear && $0.subtype == subtype }.count
                                VStack(alignment: .leading) {
                                    Text("\(subtype.rawValue) (\(itemsCount))")
                                        .font(.headline)
                                        .padding(.leading)
                                    
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 10) { // Add spacing between items
                                            // Display items in reverse order so the most recently added are first
                                            ForEach(wardrobeItems.filter { $0.type == .topWear && $0.subtype == subtype }.reversed(), id: \.id) { item in
                                                VStack {
                                                    // Use loadImage(named:) to get UIImage
                                                    if let uiImage = loadImage(named: item.imageName) {
                                                        Image(uiImage: uiImage)
                                                            .resizable()
                                                            .scaledToFit()
                                                            .frame(width: 150, height: 150)
                                                            .clipped()
                                                    } else {
                                                        // Provide a default image or placeholder if image is not found
                                                        Image(systemName: "photo")
                                                            .resizable()
                                                            .scaledToFit()
                                                            .frame(width: 200, height: 200)
                                                    }
                                                    Text(item.name)
                                                        .frame(width: 200) // Constrain text width to match image
                                                        .multilineTextAlignment(.center) // Center-align text
                                                }
                                                .frame(width: 200, height: 250) // Set frame for VStack
                                                .cornerRadius(10)
                                                .onTapGesture {
                                                    self.selectedWardrobeItem = item
                                                    self.isEditMode = true
                                                    self.navigateToItemDetailView = true
                                                    print("Selected Wardrobe Item ImageName: \(selectedWardrobeItem?.imageName ?? "No Image Name")")
                                                }
                                            }
                                        }
                                    }
                                    .frame(height: 250) // Set frame for ScrollView
                                }
                            }
                        }
                        
                        // Display bottom wear items
                        if selectedType == .bottomWear {
                            ForEach(WardrobeItemSubtype.subtypes(for: .bottomWear), id: \.self) { subtype in
                                let itemsCount = wardrobeItems.filter { $0.type == .bottomWear && $0.subtype == subtype }.count
                                VStack(alignment: .leading) {
                                    Text("\(subtype.rawValue) (\(itemsCount))")
                                        .font(.headline)
                                        .padding(.leading)
                                    
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 10) {
                                            ForEach(wardrobeItems.filter { $0.type == .bottomWear && $0.subtype == subtype }.reversed(), id: \.id) { item in
                                                VStack {
                                                    if let uiImage = loadImage(named: item.imageName) {
                                                        Image(uiImage: uiImage)
                                                            .resizable()
                                                            .scaledToFit()
                                                            .frame(width: 200, height: 200)
                                                            .clipped()
                                                    } else {
                                                        Image(systemName: "photo")
                                                            .resizable()
                                                            .scaledToFit()
                                                            .frame(width: 200, height: 200)
                                                    }
                                                    Text(item.name)
                                                        .frame(width: 200)
                                                        .multilineTextAlignment(.center)
                                                }
                                                .frame(width: 200, height: 250)
                                                .cornerRadius(10)
                                                .onTapGesture {
                                                    self.selectedWardrobeItem = item
                                                    self.isEditMode = true
                                                    self.navigateToItemDetailView = true
                                                }
                                            }
                                        }
                                    }
                                    .frame(height: 250)
                                }
                            }
                        }
                    }
                }
                
                // Buttons for navigation and adding new items
                HStack {
                    Spacer()
                    NavigationLink(destination: FavoritesView(viewModel: favoritesViewModel)) { Image(systemName: "heart.fill") }
                    
                    Spacer()
                    
                    Button(action: { self.showActionSheet = true }) { Image(systemName: "plus.circle.fill") }
                        .actionSheet(isPresented: $showActionSheet) {
                            ActionSheet(title: Text("Select Photo"), message: Text("Choose"), buttons: [
                                .default(Text("Photo Library")) {
                                    self.showImagePicker = true
                                    self.sourceType = .photoLibrary
                                },
                                .default(Text("Camera")) {
                                    self.showImagePicker = true
                                    self.sourceType = .camera
                                },
                                .cancel()
                            ])
                        }
                    //                            .sheet(isPresented: $showImagePicker, onDismiss: loadImage) {
                    //                                ImagePicker(image: self.$image, isShown: self.$showImagePicker, sourceType: self.sourceType)
                    //                            }
                        .sheet(isPresented: $showImagePicker) {
                            ImagePicker(image: self.$image, isShown: self.$showImagePicker, sourceType: self.sourceType)
                        }
                        .onChange(of: image) { newImage in
                            if let newImage = newImage {
                                self.handlePickedImage(newImage)
                            }
                        }
                    
                    
                    Spacer()
                    
                    NavigationLink(destination: PairUpView(viewModel: favoritesViewModel, wardrobeItems: $wardrobeItems)) { Image(systemName: "person.2.fill") }
                    Spacer()
                }
                
                // Navigation link for item details view
                NavigationLink(
                    destination: ImageDetailsView(
                        isEditing: selectedWardrobeItem != nil,
                        editingImageName: selectedWardrobeItem?.imageName,
                        editingItemIndex: selectedWardrobeItem != nil ? wardrobeItems.firstIndex(where: { $0.id == selectedWardrobeItem!.id }) : nil,
                        wardrobeItems: $wardrobeItems,
                        onSave: { updatedItems in
                            self.wardrobeItems = updatedItems
                            self.saveWardrobeItems(updatedItems)
                        }
                    ),
                    isActive: $navigateToItemDetailView
                ) {
                    EmptyView()
                }
            }
            .onAppear {
                // Load wardrobe items and initial launch date
                self.wardrobeItems = loadWardrobeItems()
                if let storedDate = UserDefaults.standard.object(forKey: "InitialLaunch") as? Date {
                    self.initialLaunchDate = storedDate
                } else {
                    // If the initial launch date is not stored, set it to the current date
                    let currentDate = Date()
                    UserDefaults.standard.set(currentDate, forKey: "InitialLaunch")
                    self.initialLaunchDate = currentDate
                }
                
                // Print the initial launch date to the console
                if let launchDate = self.initialLaunchDate {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateStyle = .short
                    dateFormatter.timeStyle = .none
                    let dateString = dateFormatter.string(from: launchDate)
                    print("Initial Launch Date: \(dateString)")
                } else {
                    print("Initial Launch Date not found.")
                }
            }
            .background(
                 GeometryReader { geometry in
                     Image("DarkCloset")
                         .resizable()
                         .aspectRatio(contentMode: .fill)
                         .frame(width: geometry.size.width, height: geometry.size.height)
                         .opacity(0.5) // Adjust opacity as needed
                         .edgesIgnoringSafeArea(.all) // Ignore safe area edges
                 }
             )
        }
        
    }
    
    /// Saves the given image data with the specified name.
    private func saveImage(_ imageData: Data, withName name: String) {
        guard let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let fileURL = directory.appendingPathComponent(name)
        
        do {
            try imageData.write(to: fileURL)
        } catch {
            print("Unable to save image", error.localizedDescription)
        }
    }
    
    /// Loads an image with the specified name.
    func loadImage(named imageName: String) -> UIImage? {
        guard let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        let fileURL = directory.appendingPathComponent(imageName)
        return UIImage(contentsOfFile: fileURL.path)
    }
    
    /// Saves the wardrobe items to UserDefaults.
    func saveWardrobeItems(_ items: [WardrobeItem]) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(items) {
            UserDefaults.standard.set(encoded, forKey: "WardrobeItems")
        }
    }
    
    /// Loads the wardrobe items from UserDefaults.
    func loadWardrobeItems() -> [WardrobeItem] {
        if let savedItems = UserDefaults.standard.object(forKey: "WardrobeItems") as? Data {
            let decoder = JSONDecoder()
            if let loadedItems = try? decoder.decode([WardrobeItem].self, from: savedItems) {
                return loadedItems
            }
        }
        return []
    }
    
    /// Handles the picked image by saving it and updating the wardrobe item.
    private func handlePickedImage(_ pickedImage: UIImage) {
        guard let imageData = pickedImage.jpegData(compressionQuality: 1.0) else { return }
        let imageName = UUID().uuidString + ".jpg"
        saveImage(imageData, withName: imageName)
        
        if let editingItem = selectedWardrobeItem {
            // Update existing item
            if let index = wardrobeItems.firstIndex(where: { $0.id == editingItem.id }) {
                wardrobeItems[index].imageName = imageName
            } else {
                // Handle the case where the item is not found
                print("Error: Item to update not found.")
            }
            // Update selectedWardrobeItem with the new image name
            selectedWardrobeItem?.imageName = imageName
        } else {
            // Create a new item for navigation purposes
            let newItem = WardrobeItem(name: "New Item", imageName: imageName, type: selectedType, subtype: .shirt) // Adjust subtype as needed
            selectedWardrobeItem = newItem
        }
        // Ensure navigation to ImageDetailsView
        navigateToItemDetailView = true
    }
    
    /// Updates the launch count and returns the new count.
    func updateLaunchCount() -> Int {
        let launchesKey = "numberOfLaunches"
        var currentCount = UserDefaults.standard.integer(forKey: launchesKey)
        currentCount += 1
        UserDefaults.standard.set(currentCount, forKey: launchesKey)
        return currentCount
    }
    
    /// Opens the App Store for rating.
    private func openAppStoreForRating() {
        guard let writeReviewURL = URL(string: "https://apps.apple.com/app/idYOUR_APP_ID?action=write-review")
        else { return }
        UIApplication.shared.open(writeReviewURL, options: [:], completionHandler: nil)
    }
    
    private var filteredItems: [WardrobeItem] {
        wardrobeItems.filter { $0.type == selectedType }
    }
    
    
    private func loadImage() {
        // Ensure we navigate only if a new image is selected
        // Ensure we navigate only if a new image is selected
        guard let newImage = image, newImage != lastPickedImage else {
            navigateToItemDetailView = false
            return
        }
        lastPickedImage = newImage // Update last picked image to the new image
        
        // Convert UIImage to Data
        guard let imageData = newImage.jpegData(compressionQuality: 1.0) else {
            print("Failed to convert UIImage to Data")
            return
        }
        
        // Generate a unique filename for the new image
        let imageName = UUID().uuidString + ".jpg"
        
        // Save the new image under the generated filename
        saveImage(imageData, withName: imageName)
        
        if let editingItem = selectedWardrobeItem {
            // Editing existing item
            // Create an updated item with the new imageName
            let updatedItem = WardrobeItem(name: editingItem.name, imageName: imageName, type: editingItem.type, subtype: editingItem.subtype)
            
            // Update the item in your collection
            if let index = wardrobeItems.firstIndex(where: { $0.id == editingItem.id }) {
                wardrobeItems[index] = updatedItem
            }
            isEditMode = true // We are in edit mode
        } else {
            // Adding a new item
            // Create a new WardrobeItem with the imageName
            let newItem = WardrobeItem(name: "New Item", imageName: imageName, type: .topWear, subtype: .tshirt) // Modify as necessary
            wardrobeItems.append(newItem)
            selectedWardrobeItem = newItem // Update selectedWardrobeItem if needed
            isEditMode = false // Not in edit mode
        }
        navigateToItemDetailView = true // Proceed to navigate
    }
    
    
}

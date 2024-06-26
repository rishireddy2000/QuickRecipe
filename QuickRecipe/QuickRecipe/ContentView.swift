import SwiftUI
import UIKit

struct FoodItem: Identifiable, Equatable, Hashable, Codable {
    let id = UUID()
    let name: String
    var imageName: String
    let type: FoodItemType
    let subtype: FoodItemSubtype
    
    enum CodingKeys: String, CodingKey {
        case id, name, imageName, type, subtype
    }
}

enum FoodItemType: String, CaseIterable, Codable {
    case Perishables = "Perishables"
    case Staples = "Staples"
    case Sauces = "Sauces"
    case Spices = "Spices"
    case Snacks = "Snacks"
    case Beverages = "Beverages"
}


enum FoodItemSubtype: String, CaseIterable, Codable {
    case Produce = "Produce", Dairy = "Dairy", Proteins = "Proteins"
    case Grains = "Grains", Baking = "Baking", Oils_and_Fats = "Oils and Fats"
    case Sauce = "Sauces", Condiments = "Condiments"
    case Spices = "Spices", Herbs = "Herbs", Flavorings = "Flavorings"
    case Healthy = "Healthy", Unhealthy = "Unhealthy"
    case Alcoholic = "Alocholic", Non_Alcoholic = "Non Alcoholic"

    static func subtypes(for type: FoodItemType) -> [FoodItemSubtype] {
        switch type {
        case .Perishables:
            return [.Produce, .Dairy, .Proteins]
        case .Staples:
            return [.Grains, .Baking, .Oils_and_Fats]
        case .Sauces:
            return [.Sauce, .Condiments]
        case .Spices:
            return [.Spices, .Herbs, .Flavorings]
        case .Snacks:
            return [.Healthy, .Unhealthy]
        case .Beverages:
            return [.Alcoholic, .Non_Alcoholic]
        }
    }
}


struct ContentView: View {
    @State private var showRecipeSearch = false
    @State private var showShoppingList = false
    @State private var selectedType: FoodItemType = .Perishables
    @State private var showActionSheet = false
    @State private var showImagePicker: Bool = false
    @State private var sourceType: UIImagePickerController.SourceType = .camera
    @State private var image: UIImage?
    @State private var pickedImage: UIImage?
    @State private var navigateToItemDetailView = false
    @State private var selectedFoodItem: FoodItem? = nil
    @State private var lastPickedImage: UIImage?
    @State private var isEditMode: Bool = false
    @State private var foodItems: [FoodItem] = []
    @State private var showingRatePrompt = false
    @State private var initialLaunchDate: Date?
    @Environment(\.colorScheme) var colorScheme
    
    
    
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section {
                        Picker("Select Type", selection: $selectedType) {
                            ForEach(FoodItemType.allCases, id: \.self) { type in
                                Text(type.rawValue).tag(type)
                            }
                        }
                        .pickerStyle(MenuPickerStyle()) // This makes the picker appear as a dropdown
                    }

                    Section(header: Text("Items for \(selectedType.rawValue)")) {
                        foodItemList(for: selectedType)
                    }
                }
                .navigationBarTitle("Your Kitchen")
                HStack {
                    Spacer()
                    
                    Button(action: { self.showRecipeSearch.toggle() }) {
                                        Image(systemName: "fork.knife.circle.fill")
                                            .resizable()
                                            .frame(width: 50, height: 50)
                                            .foregroundColor(.blue)
                                    }
                                    .sheet(isPresented: $showRecipeSearch) {
                                        RecipeSearchView(ingredients: ["Apple", "Sugar"])
                                    }
                                    .transition(.slide)
                    
                    Spacer()
                    PJRPulseButton(color: .blue, systemImageName: "plus.circle.fill", buttonWidth: 48, numberOfOuterCircles: 2, animationDuration: 1) {
                        self.showActionSheet = true
                    }
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
                        .sheet(isPresented: $showImagePicker) {
                            ImagePicker(image: self.$image, isShown: self.$showImagePicker, sourceType: self.sourceType)
                        }
                        .onChange(of: image) { newImage in
                            if let newImage = newImage {
                                self.handlePickedImage(newImage)
                            }
                        }

                    Spacer()
                    
                    Button(action: { self.showShoppingList.toggle() }) {
                                        Image(systemName: "bag.fill")
                                            .resizable()
                                            .frame(width: 50, height: 50)
                                            .foregroundColor(.blue)
                                    }
                                    .sheet(isPresented: $showShoppingList) {
                                        ShoppingListView()
                                    }
                                    .transition(.slide)

                    Spacer()
                    
                }
                NavigationLink(
                    destination: ImageDetailsView(
                        isEditing: selectedFoodItem != nil,
                        editingImageName: selectedFoodItem?.imageName,
                        editingItemIndex: selectedFoodItem != nil ? foodItems.firstIndex(where: { $0.id == selectedFoodItem!.id }) : nil,
                        foodItems: $foodItems,
                        onSave: { updatedItems in
                            self.foodItems = updatedItems
                            self.saveFoodItems(updatedItems)
                        }
                    ),
                    isActive: $navigateToItemDetailView
                ) {
                    EmptyView()
                }
            }
        }
        .onAppear {
            self.foodItems = loadFoodItems()
            if let storedDate = UserDefaults(suiteName: "group.com.rsr200.QuickRecipe")?.object(forKey: "InitialLaunch") as? Date {
                self.initialLaunchDate = storedDate
            } else {
                let currentDate = Date()
                UserDefaults(suiteName: "group.com.rsr200.QuickRecipe")?.set(currentDate, forKey: "InitialLaunch")
                self.initialLaunchDate = currentDate
            }
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
    }
        
        private func foodItemList(for type: FoodItemType) -> some View {
            ForEach(FoodItemSubtype.subtypes(for: type), id: \.self) { subtype in
                VStack(alignment: .leading) {
                    let itemsCount = foodItems.filter { $0.type == type && $0.subtype == subtype }.count
                    Text("\(subtype.rawValue) (\(itemsCount))")
                        .font(.headline)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 5) {
                            ForEach(foodItems.filter { $0.type == type && $0.subtype == subtype }.reversed(), id: \.id) { item in
                                foodItemView(item)
                            }
                        }
                        .frame(height: 250)
                    }
                }
            }
        }
        
        private func foodItemView(_ item: FoodItem) -> some View {
            VStack {
                if let uiImage = loadImage(named: item.imageName) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
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
                self.selectedFoodItem = item
                self.isEditMode = true
                self.navigateToItemDetailView = true
                print("Selected Wardrobe Item ImageName: \(selectedFoodItem?.imageName ?? "No Image Name")")
            }
        }

    
    private func saveImage(_ imageData: Data, withName name: String) {
        guard let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let fileURL = directory.appendingPathComponent(name)
        
        do {
            try imageData.write(to: fileURL)
        } catch {
            print("Unable to save image", error.localizedDescription)
        }
    }
    
    func loadImage(named imageName: String) -> UIImage? {
        guard let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        let fileURL = directory.appendingPathComponent(imageName)
        return UIImage(contentsOfFile: fileURL.path)
    }
    
    func saveFoodItems(_ items: [FoodItem]) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(items) {
            UserDefaults(suiteName: "group.com.rsr200.QuickRecipe")?.set(encoded, forKey: "FoodItems")
        }
    }
    
    func loadFoodItems() -> [FoodItem] {
        if let savedItems = UserDefaults(suiteName: "group.com.rsr200.QuickRecipe")?.object(forKey: "FoodItems") as? Data {
            let decoder = JSONDecoder()
            if let loadedItems = try? decoder.decode([FoodItem].self, from: savedItems) {
                return loadedItems
            }
        }
        return []
    }
    
    private func handlePickedImage(_ pickedImage: UIImage) {
        guard let imageData = pickedImage.jpegData(compressionQuality: 1.0) else {
            print("Failed to convert UIImage to Data")
            return
        }
        let imageName = UUID().uuidString + ".jpg"
        saveImage(imageData, withName: imageName)

        if let editingItem = selectedFoodItem, foodItems.contains(where: { $0.id == editingItem.id }) {
            // Updating existing item
            if let index = foodItems.firstIndex(where: { $0.id == editingItem.id }) {
                foodItems[index].imageName = imageName
                print("Updated existing item with new image")
            }
        } else {
            // Adding new item
            print("Adding new item")
            let newItem = FoodItem(name: "New Item", imageName: imageName, type: selectedType, subtype: .Produce) // Adjust subtype as needed
            foodItems.append(newItem)
            selectedFoodItem = newItem
        }
        navigateToItemDetailView = true
    }
    
    func updateLaunchCount() -> Int {
        let launchesKey = "numberOfLaunches"
        var currentCount = UserDefaults(suiteName: "group.com.rsr200.QuickRecipe")?.integer(forKey: launchesKey)
        currentCount! += 1
        UserDefaults(suiteName: "group.com.rsr200.QuickRecipe")?.set(currentCount, forKey: launchesKey)
        return currentCount!
    }
    
    private func openAppStoreForRating() {
        guard let writeReviewURL = URL(string: "https://apps.apple.com/app/idYOUR_APP_ID?action=write-review")
        else { return }
        UIApplication.shared.open(writeReviewURL, options: [:], completionHandler: nil)
    }
    
    private var filteredItems: [FoodItem] {
        foodItems.filter { $0.type == selectedType }
    }
    
    
    private func loadImage() {
        guard let newImage = image, newImage != lastPickedImage else {
            navigateToItemDetailView = false
            return
        }
        lastPickedImage = newImage
        guard let imageData = newImage.jpegData(compressionQuality: 1.0) else {
            print("Failed to convert UIImage to Data")
            return
        }
        let imageName = UUID().uuidString + ".jpg"
        saveImage(imageData, withName: imageName)
        
        if let editingItem = selectedFoodItem {
            let updatedItem = FoodItem(name: editingItem.name, imageName: imageName, type: editingItem.type, subtype: editingItem.subtype)
            if let index = foodItems.firstIndex(where: { $0.id == editingItem.id }) {
                foodItems[index] = updatedItem
            }
            isEditMode = true
        } else {
            let newItem = FoodItem(name: "New Item", imageName: imageName, type: .Perishables, subtype: .Produce) // Modify as necessary
            foodItems.append(newItem)
            selectedFoodItem = newItem
            isEditMode = false
        }
        navigateToItemDetailView = true
    }
}

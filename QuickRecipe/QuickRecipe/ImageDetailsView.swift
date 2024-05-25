import SwiftUI

struct ImageDetailsView: View {
    var isEditing: Bool
    var editingImageName: String?
    var editingItemIndex: Int?
    @Binding var foodItems: [FoodItem]
    var onSave: (([FoodItem]) -> Void)?
    @Environment(\.presentationMode) var presentationMode

    @State private var itemName: String = ""
    @State private var itemType: FoodItemType = .Perishables
    @State private var itemSubtype: FoodItemSubtype = .Produce
    @State private var image: UIImage?
    
    init(isEditing: Bool, editingImageName: String?, editingItemIndex: Int?, foodItems: Binding<[FoodItem]>, onSave: (([FoodItem]) -> Void)? = nil) {
        self.isEditing = isEditing
        self.editingImageName = editingImageName
        self.editingItemIndex = editingItemIndex
        self._foodItems = foodItems
        self.onSave = onSave

        if let index = editingItemIndex {
            let editingItem = foodItems.wrappedValue[index]
            _itemName = State(initialValue: editingItem.name)
            _itemType = State(initialValue: editingItem.type)
            _itemSubtype = State(initialValue: editingItem.subtype)
            if let loadedImage = loadImage(named: editingItem.imageName) {
                 _image = State(initialValue: loadedImage)
             }
        }
    }

    var body: some View {
        VStack {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            } else {
                Image(systemName: "photo.on.rectangle")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                    .foregroundColor(.gray)
            }

 
            TextField("Enter item name", text: $itemName)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            Picker("Type", selection: $itemType) {
                ForEach(FoodItemType.allCases, id: \.self) { type in
                    Text(type.rawValue).tag(type)
                }
            }
            .pickerStyle(SegmentedPickerStyle())

            Picker("Subtype", selection: $itemSubtype) {
                ForEach(FoodItemSubtype.subtypes(for: itemType), id: \.self) { subtype in
                    Text(subtype.rawValue).tag(subtype)
                }
            }
            .pickerStyle(SegmentedPickerStyle())

            if let index = editingItemIndex {
                   Button("Update") {
                       print("Update button clicked")
                       let imageName = editingImageName ?? UUID().uuidString + ".jpg"
                       // Save image logic here...
                       saveImage(image ?? UIImage(), withName: imageName)
                       let updatedItem = FoodItem(name: itemName, imageName: imageName, type: itemType, subtype: itemSubtype)
                       foodItems[index] = updatedItem
                       onSave?(foodItems)
                       presentationMode.wrappedValue.dismiss()
                   }
                   .padding()

                   Button("Delete") {
                       print("Item deleted")
                       foodItems.remove(at: index)
                       onSave?(foodItems)
                       presentationMode.wrappedValue.dismiss()
                   }
                   .padding()
                   .foregroundColor(.red)
               } else {
                   Button("Save") {
                       print("Save button tapped")
                       let imageName = UUID().uuidString + ".jpg"
                       saveImage(image ?? UIImage(), withName: imageName)
                       let newItem = FoodItem(name: itemName, imageName: imageName, type: itemType, subtype: itemSubtype)
                       print("Image saved successfully")
                       foodItems.append(newItem)
                       onSave?(foodItems)
                       presentationMode.wrappedValue.dismiss()
                   }
                   .padding()
               }
        }
        .onChange(of: itemType) {
            itemSubtype = FoodItemSubtype.subtypes(for: itemType).first ?? .Produce
        }
        .onAppear {
            if let editingImageName = editingImageName {
                image = loadImage(named: editingImageName)
            }
        }
        .padding()
    }
    
    func loadImage(named imageName: String) -> UIImage? {
        guard let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        let fileURL = dir.appendingPathComponent(imageName)
        print("Loading image from:", fileURL.path)
        return UIImage(contentsOfFile: fileURL.path)
    }
    

    private func saveImage(_ image: UIImage, withName imageName: String) {
        print("Saving Image to files")
        guard let data = image.jpegData(compressionQuality: 1.0) else {
            print("Failed to get JPEG representation of UIImage")
            return
        }
        guard let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Failed to find document directory")
            return
        }
        let fileURL = directory.appendingPathComponent(imageName)

        do {
            try data.write(to: fileURL)
        } catch {
            print("Failed to write image data to \(fileURL): \(error)")
        }
    }

}



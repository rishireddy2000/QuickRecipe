//
//  ImageDetailsView.swift
//  MixnMatch
//
//  Created by Prudhvi Puli on 05/03/24.
//


import SwiftUI

struct ImageDetailsView: View {
    var isEditing: Bool
    var editingImageName: String?
    var editingItemIndex: Int?
    @Binding var wardrobeItems: [WardrobeItem]
    var onSave: (([WardrobeItem]) -> Void)?
    @Environment(\.presentationMode) var presentationMode

    @State private var itemName: String = ""
    @State private var itemType: WardrobeItemType = .topWear
    @State private var itemSubtype: WardrobeItemSubtype = .shirt
    @State private var image: UIImage?
    
    /// Initializes the view with editing parameters and optional save callback.
    /// - Parameters:
    ///   - isEditing: Indicates if the view is in editing mode.
    ///   - editingImageName: The name of the image being edited.
    ///   - editingItemIndex: The index of the item being edited.
    ///   - wardrobeItems: Binding to the array of wardrobe items.
    ///   - onSave: Closure to call after saving changes.
    init(isEditing: Bool, editingImageName: String?, editingItemIndex: Int?, wardrobeItems: Binding<[WardrobeItem]>, onSave: (([WardrobeItem]) -> Void)? = nil) {
        self.isEditing = isEditing
        self.editingImageName = editingImageName
        self.editingItemIndex = editingItemIndex
        self._wardrobeItems = wardrobeItems
        self.onSave = onSave

        if let index = editingItemIndex {
            let editingItem = wardrobeItems.wrappedValue[index]
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
                ForEach(WardrobeItemType.allCases, id: \.self) { type in
                    Text(type.rawValue).tag(type)
                }
            }
            .pickerStyle(SegmentedPickerStyle())

            Picker("Subtype", selection: $itemSubtype) {
                ForEach(WardrobeItemSubtype.subtypes(for: itemType), id: \.self) { subtype in
                    Text(subtype.rawValue).tag(subtype)
                }
            }
            .pickerStyle(SegmentedPickerStyle())

            if let index = editingItemIndex {
                   // Update existing item
                   Button("Update") {
                       print("Update button clicked")
                       let imageName = editingImageName ?? UUID().uuidString + ".jpg"
                       // Save image logic here...
                       saveImage(image ?? UIImage(), withName: imageName)
                       let updatedItem = WardrobeItem(name: itemName, imageName: imageName, type: itemType, subtype: itemSubtype)
                       wardrobeItems[index] = updatedItem
                       onSave?(wardrobeItems)
                       presentationMode.wrappedValue.dismiss()
                   }
                   .padding()

                   // Delete existing item
                   Button("Delete") {
                       print("Item deleted")
                       wardrobeItems.remove(at: index)
                       onSave?(wardrobeItems)
                       presentationMode.wrappedValue.dismiss()
                   }
                   .padding()
                   .foregroundColor(.red)
               } else {
                   // Save new item
                   Button("Save") {
                       print("Save button tapped")
                       let imageName = UUID().uuidString + ".jpg"
                       saveImage(image ?? UIImage(), withName: imageName)
                       let newItem = WardrobeItem(name: itemName, imageName: imageName, type: itemType, subtype: itemSubtype)
                       print("Image saved successfully")
                       wardrobeItems.append(newItem)
                       onSave?(wardrobeItems)
                       presentationMode.wrappedValue.dismiss()
                   }
                   .padding()
               }
        }
        .onChange(of: itemType) {
            itemSubtype = WardrobeItemSubtype.subtypes(for: itemType).first ?? .shirt
        }
        .onAppear {
            if let editingImageName = editingImageName {
                image = loadImage(named: editingImageName)
            }
        }
        .padding()
    }
    
    /// Loads an image from the document directory.
    /// - Parameter imageName: The name of the image file.
    /// - Returns: The loaded image, or nil if loading fails.
    func loadImage(named imageName: String) -> UIImage? {
        guard let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        let fileURL = dir.appendingPathComponent(imageName)
        print("Loading image from:", fileURL.path)
        return UIImage(contentsOfFile: fileURL.path)
    }
    
    /// Saves an image to the document directory.
    /// - Parameters:
    ///   - image: The image to save.
    ///   - imageName: The name to use for the saved image file.
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



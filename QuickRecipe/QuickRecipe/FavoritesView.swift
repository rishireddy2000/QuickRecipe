//
//  FavoritesView.swift
//  MixnMatch
//
//  Created by Prudhvi Puli on 3/5/24.
//

import SwiftUI

struct FavoritesView: View {
    @ObservedObject var viewModel: FavoritesViewModel
    
    var body: some View {
        NavigationView {
            ZStack {
                
                List {
                    ForEach(viewModel.favoritesArray.indices.reversed(), id: \.self) { index in
                        let pair = viewModel.favoritesArray[index]
                        HStack {
                            Spacer()
                            
                            
                            VStack {
                                // Load and display the top wear image by its name
                                if let topWearImage = loadImage(named: pair.topWear.imageName) {
                                    Image(uiImage: topWearImage)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: UIScreen.main.bounds.width / 2 - 20, height: UIScreen.main.bounds.width / 2 - 20)
                                } else {
                                    Image(systemName: "photo")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: UIScreen.main.bounds.width / 2 - 20, height: UIScreen.main.bounds.width / 2 - 20)
                                }
                                Text(pair.topWear.name)
                            }
                            
                            VStack {
                                // Load and display the bottom wear image by its name
                                if let bottomWearImage = loadImage(named: pair.bottomWear.imageName) {
                                    Image(uiImage: bottomWearImage)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: UIScreen.main.bounds.width / 2 - 20, height: UIScreen.main.bounds.width / 2 - 20)
                                    
                                } else {
                                    Image(systemName: "photo")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: UIScreen.main.bounds.width / 2 - 20, height: UIScreen.main.bounds.width / 2 - 20)
                                }
                                Text(pair.bottomWear.name)
                            }
                            
                            Spacer()
                        }
                        .padding(.horizontal)
                    }
                    .onDelete(perform: deleteFavorites)
                }
                .navigationTitle("Favorites")

            }
        }

    }
    
    /// Loads an image from the document directory.
    /// - Parameter imageName: The name of the image file.
    /// - Returns: The loaded image, or nil if loading fails.
    private func loadImage(named imageName: String) -> UIImage? {
        guard let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Failed to find document directory")
            return nil
        }
        let fileURL = dir.appendingPathComponent(imageName)
        print("Loading image from:", fileURL.path)
        return UIImage(contentsOfFile: fileURL.path)
    }
    
    /// Deletes favorite clothing pairs at the specified offsets.
    /// - Parameter offsets: The offsets of the items to delete.
    private func deleteFavorites(at offsets: IndexSet) {
        let reversedOffsets = offsets.map { viewModel.favoritesArray.count - 1 - $0 }
        viewModel.favoritesArray.remove(atOffsets: IndexSet(reversedOffsets))
        viewModel.saveFavorites()
        print("Item deleted")
    }
}

struct FavoritesView_Previews: PreviewProvider {
    static var previews: some View {
        FavoritesView(viewModel: FavoritesViewModel())
    }
}

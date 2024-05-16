//
//  FavoritesViewModel.swift
//  MixnMatch
//
//  Created by Prudhvi Puli on 3/5/24.
//

import Foundation
import SwiftUI

/// Manages the favorite wardrobe pairs.
class FavoritesViewModel: ObservableObject {
    /// Array of favorite wardrobe pairs.
    @Published var favoritesArray: [WardrobePair] = [] {
        didSet {
            saveFavorites()
        }
    }
    
    /// Initializes the view model and loads favorites from storage.
    init() {
        loadFavorites()
    }
    
    /// Saves the favorite wardrobe pairs to UserDefaults
    func saveFavorites() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(favoritesArray) {
            UserDefaults.standard.set(encoded, forKey: "FavoritesArray")
        }
    }
    
    /// Loads the favorite wardrobe pairs from UserDefaults
    private func loadFavorites() {
        if let savedFavorites = UserDefaults.standard.object(forKey: "FavoritesArray") as? Data {
            let decoder = JSONDecoder()
            if let loadedFavorites = try? decoder.decode([WardrobePair].self, from: savedFavorites) {
                favoritesArray = loadedFavorites
            }
        }
    }
}

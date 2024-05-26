//
//  RecipeDetailView.swift
//  QuickRecipe
//
//  Created by Rishi Saimshu Reddy Bandi on 5/26/24.
//

import SwiftUI

struct RecipeDetailView: View {
    var recipeId: Int
    @State private var recipeDetail: RecipeDetail?
    @State private var isLoading = false

    var body: some View {
        VStack {
            if isLoading {
                ProgressView("Loading...")
            } else if let detail = recipeDetail {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text(detail.instructions)
                            .padding()
                        Link(destination: (URL(string: detail.spoonacularSourceUrl) )!, label: {
                            Text("Nutritional Information")
                        })
                    }
                }
            } else {
                Text("No details available")
            }
        }
        .onAppear {
            fetchRecipeDetails()
        }
        .navigationTitle("Recipe Details")
        .navigationBarTitleDisplayMode(.inline)
    }

    func fetchRecipeDetails() {
        isLoading = true
        guard let url = URL(string: "https://api.spoonacular.com/recipes/\(recipeId)/information?apiKey=5c1d49c5ed4948bca4af1050b57da95d") else { return }
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
                if let data = data {
                    let decoder = JSONDecoder()
                    recipeDetail = try? decoder.decode(RecipeDetail.self, from: data)
                }
            }
        }.resume()
    }
}

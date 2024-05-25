import SwiftUI

struct Recipe: Codable, Identifiable {
    var id: Int
    var title: String
    var image: String
    var summary: String
}

struct RecipeRow: View {
    var recipe: Recipe
    @State private var showDetails = false

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(recipe.title)
                Spacer()
                Button(action: { showDetails.toggle() }) {
                    Image(systemName: "chevron.down.circle")
                }
            }
            if showDetails {
                Text(recipe.summary)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
    }
}

struct RecipeSearchView: View {
    @State private var recipes = [Recipe(id: 1, title: "Test Recipe", image: "", summary: "Just a test")]
//    @State private var recipes = [Recipe]()
    @State private var isFetching = false
    var ingredients: [String]  // This should be passed from the main view

    var body: some View {
        VStack {
            if isFetching {
                ProgressView("Fetching Recipes...")
            } else {
                List(recipes, id: \.id) { recipe in
                    RecipeRow(recipe: recipe)
                }
            }
            Button("Find Recipes") {
                fetchRecipes()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
    }

    func fetchRecipes() {
        let ingredientQuery = ingredients.joined(separator: ",")
        guard let url = URL(string: "https://api.spoonacular.com/recipes/findByIngredients?ingredients=\(ingredientQuery)&apiKey=5c1d49c5ed4948bca4af1050b57da95d") else { return }
        
        isFetching = true
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                isFetching = false
                if let error = error {
                    print("Error fetching recipes: \(error.localizedDescription)")
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    print("Unexpected response status code: \((response as? HTTPURLResponse)?.statusCode ?? -1)")
                    return
                }
                
                guard let data = data else {
                    print("No data received")
                    return
                }

                print("Found recipes, raw data: \(String(describing: String(data: data, encoding: .utf8)))")
                let decoder = JSONDecoder()
                do {
                    let decodedResponse = try decoder.decode([Recipe].self, from: data)
                    recipes = decodedResponse
                } catch {
                    print("Failed to decode JSON: \(error.localizedDescription)")
                }
            }
        }.resume()
    }
}


#Preview {
    RecipeSearchView(ingredients: ["Apple","Sugar"])
}

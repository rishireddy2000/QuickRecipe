import SwiftUI

struct Recipe: Codable, Identifiable {
    var id: Int
    var title: String
    var image: String
    var summary: String?
    var usedIngredientCount: Int?
    var missedIngredientCount: Int?
    var likes: Int?
    var missedIngredients : [Ingredient]?

    enum CodingKeys: String, CodingKey {
        case id, title, image, summary, usedIngredientCount, missedIngredientCount, likes, missedIngredients
    }
}

struct RecipeDetail: Codable {
    var sourceUrl: String
    var instructions: String
    var spoonacularSourceUrl : String
}

struct Ingredient: Codable {
    var id: Int
    var amount: Double
    var unit: String
    var name: String
    var original: String
}

struct RecipeRow: View {
    var recipe: Recipe
    @State private var showDetails = false


    var body: some View {
        NavigationLink(destination: RecipeDetailView(recipeId: recipe.id)) {
                HStack {
                    Text(recipe.title)
                    Spacer()
                }
            }
        }
}


struct RecipeSearchView: View {
    @State private var recipes = [Recipe]()
    @State private var isFetching = false
    var ingredients: [String]  // This should be passed from the main view

    var body: some View {
            NavigationView {
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
                .navigationTitle("Recipes")
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
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                decoder.dateDecodingStrategy = .iso8601
                do {
                    let decodedResponse = try decoder.decode([Recipe].self, from: data)
                    recipes = decodedResponse.sorted { $0.missedIngredientCount ?? 0 < $1.missedIngredientCount ?? 0 }
                } catch {
                    print("Failed to decode JSON: \(error)")
                }
                do {
                    let decodedResponse = try decoder.decode([Recipe].self, from: data)
                    recipes = decodedResponse.sorted { $0.missedIngredientCount ?? 0 < $1.missedIngredientCount ?? 0 }
                    print("Recipes loaded successfully!")
                } catch let DecodingError.dataCorrupted(context) {
                    print(context)
                } catch let DecodingError.keyNotFound(key, context) {
                    print("Key '\(key)' not found:", context.debugDescription)
                    print("codingPath:", context.codingPath)
                } catch let DecodingError.valueNotFound(value, context) {
                    print("Value '\(value)' not found:", context.debugDescription)
                    print("codingPath:", context.codingPath)
                } catch let DecodingError.typeMismatch(type, context)  {
                    print("Type '\(type)' mismatch:", context.debugDescription)
                    print("codingPath:", context.codingPath)
                } catch {
                    print("error: ", error)
                }
                
            }
        }.resume()
    }
}



import SwiftUI

struct ShoppingListView: View {
    @State private var newItem: String = ""
    @State private var items: [String] = []

    var body: some View {
        VStack {
            List {
                ForEach(items, id: \.self) { item in
                    Text(item)
                }
                .onDelete(perform: delete)
            }
            
            HStack {
                TextField("Add new item", text: $newItem, onCommit: addItem)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Button(action: addItem) {
                    Image(systemName: "plus")
                        .foregroundColor(.green)
                }
            }
        }
        .onAppear(perform: loadItems)
    }
    
    func addItem() {
        guard !newItem.isEmpty else { return }
        items.append(newItem)
        newItem = "" // Clear the text field
        saveItems()
    }
    
    func delete(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
        saveItems()
    }

    func saveItems() {
        UserDefaults(suiteName: "group.com.rsr200.QuickRecipe")?.set(items, forKey: "ShoppingListItems")
        UserDefaults(suiteName: "group.com.rsr200.QuickRecipe")?.synchronize()
    }
    
    func loadItems() {
        if let savedItems = UserDefaults(suiteName: "group.com.rsr200.QuickRecipe")?.object(forKey: "ShoppingListItems") as? [String] {
            items = savedItems
        }
    }
}

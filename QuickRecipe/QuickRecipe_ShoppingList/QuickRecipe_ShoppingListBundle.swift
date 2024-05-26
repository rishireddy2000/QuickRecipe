import WidgetKit
import SwiftUI

struct MyWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
            print("Placeholder called")
            let data = UserDefaults.standard.stringArray(forKey: "group.com.rsr200.QuickRecipe") ?? ["Default Value"]
            print("Placeholder data:", data)
            let names = data.map { $0.components(separatedBy: " ").first ?? "Unknown" } // Extracting the first part as the name
            print("Extracted names:", names)
            let entry = SimpleEntry(date: Date(), names: names)
            return entry
        }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        print("Get snapshot called")
        let data = UserDefaults(suiteName: "group.com.rsr200.QuickRecipe")?.stringArray(forKey: "ShoppingListItems") ?? ["Default Value"]
        print("Snapshot data:", data)
        let names = data.map { $0.components(separatedBy: " ").first ?? "Unknown" }
        let entry = SimpleEntry(date: Date(), names: names)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        // Retrieve the latest data from UserDefaults
            let data = UserDefaults(suiteName: "group.com.rsr200.QuickRecipe")?.stringArray(forKey: "ShoppingListItems") ?? ["Default Value"]
            let currentDate = Date()
            let nextRefreshDate = Calendar.current.date(byAdding: .second, value: 1, to: currentDate) ?? Date()
            
            // Update the names with the latest data
            let names = data.map { $0.components(separatedBy: " ").first ?? "Unknown" }

            // Create a timeline entry for the next refresh
            let entry = SimpleEntry(date: currentDate, names: names)
            let timeline = Timeline(entries: [entry], policy: .after(nextRefreshDate))
            
            // Call completion with the timeline
            completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let names: [String]
}

struct MyWidgetEntryView : View {
    var entry: MyWidgetProvider.Entry

    var body: some View {
        print("Widget entry view updated at:", entry.date)
        return VStack(alignment: .leading) {
            Text("Your Shopping List:")
            Spacer()
            ForEach(entry.names, id: \.self) { name in
                Text(name).padding(.leading)
            }
            Spacer()
        }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(Color.black)
            .foregroundColor(.white)
    }
}

@main
struct QuickRecipe_ShoppingList: Widget {
    let kind: String = "MyWidget"

    var body: some WidgetConfiguration {
        print("Widget body called")
        return StaticConfiguration(kind: kind, provider: MyWidgetProvider()) { entry in
            MyWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

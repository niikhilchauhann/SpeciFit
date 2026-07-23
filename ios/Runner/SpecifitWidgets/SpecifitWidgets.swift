import WidgetKit
import SwiftUI

private let appGroupId = "group.com.edencorp.myfitnessapp"

// MARK: - Water Widget
struct WaterProvider: TimelineProvider {
    func placeholder(in context: Context) -> WaterEntry {
        WaterEntry(date: Date(), text: "0 / 4000 ml", progress: 0)
    }

    func getSnapshot(in context: Context, completion: @escaping (WaterEntry) -> ()) {
        let entry = WaterEntry(date: Date(), text: "2000 / 4000 ml", progress: 50)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WaterEntry>) -> ()) {
        let userDefaults = UserDefaults(suiteName: appGroupId)
        let text = userDefaults?.string(forKey: "water_text") ?? "0 / 4000 ml"
        let progress = userDefaults?.integer(forKey: "water_progress_int") ?? 0
        
        let entry = WaterEntry(date: Date(), text: text, progress: progress)
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }
}

struct WaterEntry: TimelineEntry {
    let date: Date
    let text: String
    let progress: Int
}

struct WaterWidgetEntryView : View {
    var entry: WaterProvider.Entry

    var body: some View {
        VStack {
            Text("Water").font(.headline)
            ProgressView(value: Double(entry.progress), total: 100)
                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                .padding(.vertical, 8)
            Text(entry.text).font(.subheadline).foregroundColor(.secondary)
        }
        .padding()
    }
}

struct WaterWidget: Widget {
    let kind: String = "WaterWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WaterProvider()) { entry in
            WaterWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Water Tracker")
        .description("Track your daily water intake.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: - Steps Widget
struct StepsProvider: TimelineProvider {
    func placeholder(in context: Context) -> StepsEntry {
        StepsEntry(date: Date(), text: "0 / 10000", progress: 0)
    }

    func getSnapshot(in context: Context, completion: @escaping (StepsEntry) -> ()) {
        let entry = StepsEntry(date: Date(), text: "5000 / 10000", progress: 50)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<StepsEntry>) -> ()) {
        let userDefaults = UserDefaults(suiteName: appGroupId)
        let text = userDefaults?.string(forKey: "steps_text") ?? "0 / 10000"
        let progress = userDefaults?.integer(forKey: "steps_progress_int") ?? 0
        
        let entry = StepsEntry(date: Date(), text: text, progress: progress)
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }
}

struct StepsEntry: TimelineEntry {
    let date: Date
    let text: String
    let progress: Int
}

struct StepsWidgetEntryView : View {
    var entry: StepsProvider.Entry

    var body: some View {
        VStack {
            Text("Steps").font(.headline)
            ProgressView(value: Double(entry.progress), total: 100)
                .progressViewStyle(LinearProgressViewStyle(tint: .green))
                .padding(.vertical, 8)
            Text(entry.text).font(.subheadline).foregroundColor(.secondary)
        }
        .padding()
    }
}

struct StepsWidget: Widget {
    let kind: String = "StepsWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: StepsProvider()) { entry in
            StepsWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Steps Tracker")
        .description("Track your daily steps.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: - Calories Widget
struct CaloriesProvider: TimelineProvider {
    func placeholder(in context: Context) -> CaloriesEntry {
        CaloriesEntry(date: Date(), text: "0 kcal")
    }

    func getSnapshot(in context: Context, completion: @escaping (CaloriesEntry) -> ()) {
        let entry = CaloriesEntry(date: Date(), text: "2000 kcal")
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<CaloriesEntry>) -> ()) {
        let userDefaults = UserDefaults(suiteName: appGroupId)
        let text = userDefaults?.string(forKey: "calories_text") ?? "0 kcal"
        
        let entry = CaloriesEntry(date: Date(), text: text)
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }
}

struct CaloriesEntry: TimelineEntry {
    let date: Date
    let text: String
}

struct CaloriesWidgetEntryView : View {
    var entry: CaloriesProvider.Entry

    var body: some View {
        VStack {
            Text("Calories").font(.headline)
            Text(entry.text)
                .font(.title2)
                .bold()
                .foregroundColor(.orange)
                .padding(.top, 8)
        }
        .padding()
    }
}

struct CaloriesWidget: Widget {
    let kind: String = "CaloriesWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: CaloriesProvider()) { entry in
            CaloriesWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Calories Tracker")
        .description("Track your daily calories.")
        .supportedFamilies([.systemSmall])
    }
}

// MARK: - Widget Bundle
@main
struct SpecifitWidgetsBundle: WidgetBundle {
    var body: some Widget {
        WaterWidget()
        StepsWidget()
        CaloriesWidget()
    }
}

import WidgetKit
import SwiftUI


@main
struct HomeWidgetBundle: WidgetBundle {
    var body: some Widget {
        HomeWidget()
        HomeWidgetLiveActivity()
    }
}

@available(iOS 15.0, *)
struct HomeWidget: Widget {
    let kind: String = "HomeWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            HomeWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("次の授業ウィジェット")
        .description("ホーム画面に次の授業の教室と時限を表示します。")
        .supportedFamilies(supportedFamilies)
        .contentMarginsDisabledIfAvailable()
    }
}

@available(iOS 14.0, *)
struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), widgetData: WidgetData(classRoom: "404教室", className: "Not Found", period: "x", startTime: "H:mm~"))
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        let entry = loadEntry()
        completion(entry)
    }


    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> Void) {
        getSnapshot(in: context) { entry in
            let currentDate = Date()
            let nextUpdateDate = nextClassTime(from: currentDate) ?? Calendar.current.date(byAdding: .minute, value: 15, to: currentDate)!
            let timeline = Timeline(entries: [entry], policy: .after(nextUpdateDate))
            completion(timeline)
        }
    }
    
    private func loadEntry() -> SimpleEntry {
        let sharedDefaults = UserDefaults(suiteName: "group.com.example.wasedule")
        var widgetData: WidgetData? = nil
        
        if let data = sharedDefaults?.string(forKey: "widgetData")?.data(using: .utf8) {
            do {
                widgetData = try JSONDecoder().decode(WidgetData.self, from: data)
               // print("Decoded widget data: \(widgetData!)")  // デバッグログ
            } catch {
               // print("Error decoding widget data: \(error)")
                widgetData = WidgetData(classRoom: "エラー", className: "デコード失敗", period: "N/A", startTime: "N/A")
            }
        } else {
            print("No data found in UserDefaults")
        }
        
        return SimpleEntry(date: Date(), widgetData: widgetData)
    }
    private func nextClassTime(from date: Date) -> Date? {
        let classTimes = [
            "08:50", "10:40", "12:40","13:10", "15:05", "17:00", "18:55", "20:45", "22:00"
        ]
        //12:40は

        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        
        for classTime in classTimes {
            if let classDate = dateFormatter.date(from: classTime),
               let nextClassDate = calendar.date(bySettingHour: calendar.component(.hour, from: classDate), minute: calendar.component(.minute, from: classDate), second: 0, of: date) {
                if nextClassDate > date {
                    return calendar.date(byAdding: .minute, value: -30, to: nextClassDate)
                }
            }
        }
        
        return nil
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let widgetData: WidgetData?
}

struct WidgetData: Decodable, Hashable {
    let classRoom: String
    let className: String
    let period: String
    let startTime: String
}

@available(iOS 15.0, *)
struct HomeWidgetEntryView: View {
    var entry: SimpleEntry
    
    var body: some View {
        VStack(alignment: .leading) {
            if let widgetData = entry.widgetData {
                Text("次の授業")
                    .font(.headline)
                Text("\(widgetData.period) 限: \(widgetData.className)")
                    .font(.subheadline)
                Text("教室: \(widgetData.classRoom)")
                    .font(.subheadline)
                Text("時間: \(widgetData.startTime)")
                    .font(.subheadline)
            } else {
                Text("データがありません")
                    .font(.headline)
            }
        }
        .padding()
        .widgetBackground(Color.clear)
    }
}

@available(iOS 15.0, *)
private var supportedFamilies: [WidgetFamily] {
    if #available(iOS 16.0, *) {
        return [
            .systemSmall,
            .systemMedium,
            .systemLarge,
            .accessoryCircular,
            .accessoryRectangular
        ]
    } else {
        return [
            .systemSmall,
            .systemMedium,
            .systemLarge,
            .systemExtraLarge
        ]
    }
}

@available(iOS 15.0, *)
extension View {
    @ViewBuilder
    func widgetBackground(_ style: some ShapeStyle) -> some View {
        if #available(iOS 17.0, *) {
            self.containerBackground(for: .widget) {
                ContainerRelativeShape().fill(style)
            }
        } else {
            self.background(ContainerRelativeShape().fill(style))
        }
    }
}

@available(iOS 15.0, *)
extension WidgetConfiguration {
    func contentMarginsDisabledIfAvailable() -> some WidgetConfiguration {
            return self.contentMarginsDisabled()
    }
}


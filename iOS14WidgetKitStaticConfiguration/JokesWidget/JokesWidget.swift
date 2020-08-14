//
//  JokesWidget.swift
//  JokesWidget
//
//  Created by Anupam Chugh on 01/07/20.
//

import WidgetKit
import SwiftUI

struct SimpleEntry: TimelineEntry {
    public let date: Date
    public let covidCases : String
    public let covidRecovered : String
    public let covidDeaths : String
    
}

public struct PlaceholderView : View {
    public var body: some View {
        Text("Placeholder View")
    }
}

struct JokeProvider: TimelineProvider {
    public func snapshot(with context: Context, completion: @escaping (JokesEntry) -> ()) {
        let entry = JokesEntry(date: Date(), joke: "...")
        completion(entry)
    }

    public func timeline(with context: Context,
                         completion: @escaping (Timeline<Entry>) -> ()) {
        
        DataFetcher.shared.getJokes{
            response in

            let date = Date()
            let calendar = Calendar.current
                        
            let entries = response?.enumerated().map { offset, currentJoke in
                JokesEntry(date: calendar.date(byAdding: .second, value: offset*2, to: date)!, joke: currentJoke.joke ?? "...")
            }

            let timeLine = Timeline(entries: entries ?? [], policy: .atEnd)
            
            completion(timeLine)
            
        }
    }
}



struct JokesEntry: TimelineEntry {
    public let date: Date
    public let joke : String
}


struct JokesWidgetEntryView : View {
    var entry: JokeProvider.Entry
    
    @Environment(\.widgetFamily) var family

    @ViewBuilder
    var body: some View {
        
        switch family {
        case .systemSmall:
            Text(entry.joke)
                .minimumScaleFactor(0.3)
                .padding(.all, 5)
        default:
            VStack{
            
            Text("Chuck Norris Cracks:")
                .font(.system(.headline, design: .rounded))
                .padding()
                
            Text(entry.joke)
                .minimumScaleFactor(0.3)
                .padding(.all, 5)
                
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            .background(Color.pink)
        }

    }
}


struct JokesWidget: Widget {
    private let kind: String = "JokesWidget"

    public var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: JokeProvider(), placeholder: PlaceholderView()) { entry in
            JokesWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Jokes Widget")
        .description("This is a widget")
    }
}


@main
struct MyWidgetBundle: WidgetBundle {
    @WidgetBundleBuilder
    var body: some Widget {
        //AddYourWidgetHere()
        JokesWidget()
    }
}

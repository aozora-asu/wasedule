//
//  HomeWidgetExtensionLiveActivity.swift
//  HomeWidgetExtension
//
//  Created by Ryotaro Takatsu on 2024/06/24.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct HomeWidgetExtensionAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct HomeWidgetExtensionLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: HomeWidgetExtensionAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension HomeWidgetExtensionAttributes {
    fileprivate static var preview: HomeWidgetExtensionAttributes {
        HomeWidgetExtensionAttributes(name: "World")
    }
}

extension HomeWidgetExtensionAttributes.ContentState {
    fileprivate static var smiley: HomeWidgetExtensionAttributes.ContentState {
        HomeWidgetExtensionAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: HomeWidgetExtensionAttributes.ContentState {
         HomeWidgetExtensionAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: HomeWidgetExtensionAttributes.preview) {
   HomeWidgetExtensionLiveActivity()
} contentStates: {
    HomeWidgetExtensionAttributes.ContentState.smiley
    HomeWidgetExtensionAttributes.ContentState.starEyes
}

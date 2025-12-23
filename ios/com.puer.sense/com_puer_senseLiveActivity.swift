//
//  com_puer_senseLiveActivity.swift
//  com.puer.sense
//
//  Created by Joseph-M2 on 2025/12/23.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct com_puer_senseAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct com_puer_senseLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: com_puer_senseAttributes.self) { context in
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

extension com_puer_senseAttributes {
    fileprivate static var preview: com_puer_senseAttributes {
        com_puer_senseAttributes(name: "World")
    }
}

extension com_puer_senseAttributes.ContentState {
    fileprivate static var smiley: com_puer_senseAttributes.ContentState {
        com_puer_senseAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: com_puer_senseAttributes.ContentState {
         com_puer_senseAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: com_puer_senseAttributes.preview) {
   com_puer_senseLiveActivity()
} contentStates: {
    com_puer_senseAttributes.ContentState.smiley
    com_puer_senseAttributes.ContentState.starEyes
}

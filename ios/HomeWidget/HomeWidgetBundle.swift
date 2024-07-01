//
//  HomeWidgetBundle.swift
//  HomeWidget
//
//  Created by Ryotaro Takatsu on 2024/06/29.
//

import WidgetKit
import SwiftUI

@main
struct HomeWidgetBundle: WidgetBundle {
    var body: some Widget {
        HomeWidget()
        HomeWidgetLiveActivity()
    }
}

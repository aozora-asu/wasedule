//
//  HomeWidgetBundle.swift
//  HomeWidget
//
//  Created by 矢澤駿 on 2024/07/06.
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

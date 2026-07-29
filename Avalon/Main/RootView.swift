//
//  RootView.swift
//  Avalon
//
//  Created by Ben Key on 7/28/26.
//

import SwiftUI

struct RootView: View {
    @State private var currentTab: Int = 1
    
    var body: some View {
        TabView(selection: $currentTab) {
            Tab("Settings", systemImage: "gear", value: 0) {
                SettingsView()
            }
            
            Tab("Game", systemImage: "gamecontroller", value: 1) {
                JoinView()
            }
        }
        .tint(.blue1)
    }
}

#Preview {
    RootView()
}

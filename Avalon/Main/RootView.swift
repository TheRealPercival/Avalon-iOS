//
//  RootView.swift
//  Avalon
//
//  Created by Ben Key on 7/28/26.
//

import SwiftUI

struct RootView: View {
    var body: some View {
        TabView {
            Tab("Settings", systemImage: "gear") {
                SettingsView()
            }
            
            Tab("Game", systemImage: "gamecontroller") {
                JoinView()
            }
        }
        .tint(.blue1)
    }
}

#Preview {
    RootView()
}

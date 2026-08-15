//
//  RootView.swift
//  Avalon
//
//  Created by Ben Key on 7/28/26.
//

import SwiftUI
import SocketIO
import Supabase

struct RootView: View {
    @State private var currentTab: Int = 1
    
    private let setupConfig: SetupConfig.CompleteConfig
    
    init(setupConfig: SetupConfig.CompleteConfig) {
        self.setupConfig = setupConfig
    }
    
    var body: some View {
        TabView(selection: $currentTab) {
            Tab("Settings", systemImage: "gear", value: 0) {
                SettingsView(
                    isAdmin: true,
                    setupConfig: setupConfig
                )
            }
            
            Tab("Game", systemImage: "gamecontroller", value: 1) {
                JoinView()
            }
        }
        .tint(.blue1)
    }
}

#if DEBUG
#Preview {
    RootView(setupConfig: .preview)
}
#endif

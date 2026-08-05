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
    
    @Binding private var socketManager: SocketManager?
    @Binding private var serverInfo: ServerInfo?
    @Binding private var supabaseClient: SupabaseClient?
    
    init(
        socketManager: Binding<SocketManager?>,
        serverInfo: Binding<ServerInfo?>,
        supabaseClient: Binding<SupabaseClient?>
    ) {
        self._socketManager = socketManager
        self._serverInfo = serverInfo
        self._supabaseClient = supabaseClient
    }
    
    var body: some View {
        TabView(selection: $currentTab) {
            Tab("Settings", systemImage: "gear", value: 0) {
                SettingsView(
                    isAdmin: true,
                    socketManager: $socketManager,
                    serverInfo: $serverInfo,
                    supabaseClient: $supabaseClient
                )
            }
            
            Tab("Game", systemImage: "gamecontroller", value: 1) {
                JoinView()
            }
        }
        .tint(.blue1)
    }
}

#Preview {
//    RootView()
}

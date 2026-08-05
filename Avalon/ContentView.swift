//
//  ContentView.swift
//  Avalon
//
//  Created by Ben Key on 7/24/26.
//

import SwiftUI
import SwiftData
import SocketIO
import Supabase

struct ContentView: View {
    @State private var socketManager: SocketManager?
    @State private var serverInfo: ServerInfo?
    @State private var supabaseClient: SupabaseClient?
    
    init() {
        UIScrollView.appearance().delaysContentTouches = false
    }
    
    var body: some View {
        if let socketManager, let serverInfo, let supabaseClient {
            RootView(
                socketManager: $socketManager,
                serverInfo: $serverInfo,
                supabaseClient: $supabaseClient
            )
        } else {
            SetupView(
                socketManager: $socketManager,
                serverInfo: $serverInfo,
                supabaseClient: $supabaseClient
            )
        }
    }
}

#Preview {
    ContentView()
}

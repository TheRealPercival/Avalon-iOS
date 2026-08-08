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
    @State private var setupConfig: SetupConfig = .init()
    
    init() {
        UIScrollView.appearance().delaysContentTouches = false
    }
    
    var body: some View {
        if let completeConfig = setupConfig.complete {
            RootView(setupConfig: completeConfig)
        } else {
            SetupView(setupConfig: $setupConfig)
        }
    }
}

#Preview {
    ContentView()
}

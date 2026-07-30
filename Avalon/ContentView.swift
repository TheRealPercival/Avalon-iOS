//
//  ContentView.swift
//  Avalon
//
//  Created by Ben Key on 7/24/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var isSetupComplete: Bool = false
    
    init() {
        UIScrollView.appearance().delaysContentTouches = false
    }
    
    var body: some View {
        if isSetupComplete {
            RootView()
        } else {
            SetupView(isSetupComplete: $isSetupComplete)
        }
    }
}

#Preview {
    ContentView()
}

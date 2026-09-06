//
//  GameView.swift
//  Avalon
//
//  Created by Ben Key on 8/30/26.
//

import SwiftUI
import SocketIO

struct GameView: View {
    private let setupConfig: SetupConfig.CompleteConfig
    
    init(setupConfig: SetupConfig.CompleteConfig) {
        self.setupConfig = setupConfig
    }
    
    var body: some View {
        LobbyView(setupConfig: setupConfig)
    }
}

#Preview {
    GameView(setupConfig: .preview)
}

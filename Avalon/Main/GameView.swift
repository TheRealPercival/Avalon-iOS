//
//  GameView.swift
//  Avalon
//
//  Created by Ben Key on 8/30/26.
//

import SwiftUI
import SocketIO

struct GameView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: GameViewModel = .init()
    
    private let setupConfig: SetupConfig.CompleteConfig
    
    init(setupConfig: SetupConfig.CompleteConfig) {
        self.setupConfig = setupConfig
    }
    
    var body: some View {
        Group {
            LobbyView()
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                backButton
            }
        }
    }
}

extension GameView {
    private var backButton: some View {
        Button("Back", systemImage: "chevron.left") {
            viewModel.isRequestingToLeave = true
        }
        .confirmationDialog(
            "Are you sure?",
            isPresented: $viewModel.isRequestingToLeave,
            titleVisibility: .visible
        ) {
            Button("Leave", role: .destructive) {
                viewModel.requestToLeaveSession(for: socket) {
                    dismiss()
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Do you really want to leave the session?")
        }
    }
    
    private var socket: SocketIOClient {
        setupConfig.socketManager.defaultSocket
    }
}

#Preview {
    GameView(setupConfig: .preview)
}

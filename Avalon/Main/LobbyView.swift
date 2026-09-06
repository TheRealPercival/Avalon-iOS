//
//  LobbyView.swift
//  Avalon
//
//  Created by Ben Key on 9/6/26.
//

import SwiftUI
import SocketIO

struct LobbyView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: LobbyViewModel = .init()
    
    private let setupConfig: SetupConfig.CompleteConfig
    
    init(setupConfig: SetupConfig.CompleteConfig) {
        self.setupConfig = setupConfig
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                AvalonSection("Preset") {}
                AvalonSection("Roles") {}
                AvalonSection("Settings") {}
                AvalonSection("Players") {}
            }
            .padding(16)
            .frame(maxWidth: .infinity)
        }
        .scrollBounceBehavior(.basedOnSize)
        .navigationBarBackButtonHidden()
        .background {
            Color.fullBackground
                .ignoresSafeArea()
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                backButton
            }
            
            ToolbarItem(placement: .title) {
                Text("Lobby")
                    .font(.livvic(size: .subheading))
            }
        }
    }
}

extension LobbyView {
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
    LobbyView(setupConfig: .preview)
}

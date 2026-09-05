//
//  JoinView.swift
//  Avalon
//
//  Created by Ben Key on 7/29/26.
//

import SwiftUI
import SocketIO

struct JoinView: View {
    @State private var viewModel: JoinViewModel = .init()
    
    private let setupConfig: SetupConfig.CompleteConfig
    
    init(setupConfig: SetupConfig.CompleteConfig) {
        self.setupConfig = setupConfig
    }
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 0) {
                    AvalonHeader()
                    
                    Spacer()
                    
                    VStack(spacing: 12) {
                        joinButton
                    }
                    
                    Spacer()
                }
                .padding(16)
                .frame(maxWidth: .infinity, minHeight: geometry.size.height)
            }
            .scrollBounceBehavior(.basedOnSize)
            .background {
                Color.fullBackground
                    .ignoresSafeArea()
            }
            .onChange(of: setupConfig.serverStatus) {
                viewModel.onServerStatusChange(for: socket)
            }
            .onAppear {
                viewModel.listenToSessionEvents(from: socket)
            }
        }
    }
}

extension JoinView {
    private var joinButton: some View {
        AvalonButton(buttonTitle) {
            viewModel.requestToJoinSession(for: socket)
        } trailingView: {
            StackedProfilePictures {
                ForEach(viewModel.inSessionUsers.prefix(3)) { user in
                    AsyncImage(url: user.avatarURL) { content in
                        content.image?
                            .resizable()
                            .scaledToFit()
                    }
                }
            }
        }
        .disabled(setupConfig.serverStatus != .connected)
        .navigationDestination(isPresented: $viewModel.isOnGameScreen) {
            GameView(setupConfig: setupConfig)
        }
        .onChange(of: viewModel.isInSession, viewModel.handleSessionStatusChange)
        .onChange(of: viewModel.isOnGameScreen) {
            viewModel.handleGameNavigationChange(for: socket)
        }
    }
    
    private var socket: SocketIOClient {
        setupConfig.socketManager.defaultSocket
    }
    
    private var buttonTitle: String {
        guard !viewModel.inSessionUsers.isEmpty else {
            return "Start Game"
        }
        
        return "Join Game (\(viewModel.inSessionUsers.count) in lobby)"
    }
}

#Preview {
    JoinView(setupConfig: .preview)
}

//
//  SetupView.swift
//  Avalon
//
//  Created by Ben Key on 7/24/26.
//

import SwiftUI
import SocketIO
import Supabase

struct SetupView: View {
    @ScaledMetric private var logoHeight = 18
    @State private var viewModel: SetupViewModel = .init()
    @Binding private var setupConfig: SetupConfig

    init(setupConfig: Binding<SetupConfig>) {
        self._setupConfig = setupConfig
    }
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 0) {
                    AvalonHeader()
                    
                    if let socketManager = setupConfig.socketManager,
                       let serverInfo = setupConfig.serverInfo {
                        signInView(using: socketManager, with: serverInfo)
                            .transition(
                                .offset(x: geometry.size.width)
                            )
                    } else {
                        serverURLView
                            .transition(
                                .offset(x: -geometry.size.width)
                            )
                    }
                }
                .padding(16)
                .frame(maxWidth: .infinity, minHeight: geometry.size.height)
            }
            .scrollBounceBehavior(.basedOnSize)
            .background {
                Color.fullBackground
                    .ignoresSafeArea()
            }
        }
    }
    
    private var serverURLView: some View {
        VStack(spacing: 0) {
            Spacer()
            
            VStack(spacing: 48) {
                VStack(spacing: 12) {
                    Text("You've arrived in Avalon!")
                        .foregroundStyle(.primaryText)
                        .font(.livvic(size: .subheading))
                    
                    Text("Welcome to an online adaptation of Don Eskridge's Avalon: Big Box Edition. Please enter your group's server URL below to begin.")
                        .foregroundStyle(.secondaryText)
                        .font(.livvic(size: .note))
                }
                .multilineTextAlignment(.center)
                
                VStack(spacing: 8) {
                    TextField(
                        "Server URL",
                        text: $viewModel.serverURLString,
                        prompt: Text("Server URL").foregroundStyle(.subtleText)
                    )
                    .keyboardType(.URL)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .foregroundStyle(.primaryText)
                    .font(.livvic)
                    .padding(12)
                    .disabled(setupConfig.serverStatus.active)
                    .overlay {
                        RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(viewModel.serverURLErrorString == nil ? .tertiaryText : .red2)
                    }
                    
                    Text(viewModel.serverURLErrorString ?? "\u{200B}")
                        .foregroundStyle(.red2)
                        .font(.livvic(size: .note))
                        .fixedSize()
                        .onChange(of: viewModel.serverURLString) {
                            viewModel.serverURLErrorString = nil
                        }
                }
            }
            
            Spacer()
            
            AvalonButton(viewModel.connectButtonText(for: setupConfig.serverStatus)) {
                viewModel.connectToServer(setupConfig: setupConfig)
            }
            .disabled(setupConfig.serverStatus.active)
            .opacity(setupConfig.serverStatus.active ? 0.35 : 1)
        }
    }
    
    private func signInView(using socketManager: SocketManager, with serverInfo: ServerInfo) -> some View {
        VStack(spacing: 0) {
            Spacer()
            
            VStack(spacing: 48) {
                VStack(spacing: 12) {
                    Text("Identify yourself!")
                        .foregroundStyle(.primaryText)
                        .font(.livvic(size: .subheading))
                    
                    Text("Sign into your Discord account below so your game history can be saved.")
                        .foregroundStyle(.secondaryText)
                        .font(.livvic(size: .note))
                }
                
                VStack(spacing: 8) {
                    Button {
                        Task {
                            await viewModel.signIn(
                                setupConfig: setupConfig,
                                socketManager: socketManager,
                                serverInfo: serverInfo
                            )
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Image(.discordLogo)
                                .resizable()
                                .scaledToFit()
                                .frame(height: logoHeight)
                            
                            Text("Sign in with Discord")
                                .foregroundStyle(.white1)
                                .font(.livvic(weight: .medium))
                        }
                        .padding(12)
                        .frame(maxWidth: .infinity)
                        .background(.blurple)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    
                    Text("Connected to \(socketManager.socketURL.absoluteString)")
                        .font(.livvic(size: .note))
                        .foregroundStyle(.tertiaryText)
                }
            }
            .multilineTextAlignment(.center)
            
            Spacer()
        }
    }
}

struct ServerInfo: Decodable {
    let version: String
    let supabaseURL: URL
    let supabaseAnonKey: String
}

#Preview {
    SetupView(setupConfig: .constant(.init()))
}

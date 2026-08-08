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
    
    @State private var serverURLString: String = ""
    @State private var status: SocketIOStatus = .notConnected
    
    @Binding private var setupConfig: SetupConfig

    init(
        setupConfig: Binding<SetupConfig>
    ) {
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
                
                TextField(
                    "Server URL",
                    text: $serverURLString,
                    prompt: Text("Server URL").foregroundStyle(.subtleText)
                )
                .keyboardType(.URL)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .foregroundStyle(.primaryText)
                .font(.livvic)
                .padding(12)
                .disabled(status == .connecting)
                .overlay {
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(.tertiaryText)
                }
            }
            
            Spacer()
            
            AvalonButton(buttonText) {
                // Connect to WebSocket server to verify
                guard let serverURL = URL(string: serverURLString) else {
                    // Throw error message to user
                    print("Error: Invalid URL")
                    return
                }
                
                let socketManager = SocketManager(
                    socketURL: serverURL,
                    config: [.log(true), .compress]
                )
                
                setupConfig.socketManager = socketManager
                
                let socket = socketManager.defaultSocket
                status = socket.status
                    
                socket.on(clientEvent: .connect) { _, _ in
                    print(".connect")
                }
                
                socket.on(clientEvent: .disconnect) { _, _ in
                    print(".disconnect")
                }
                
                socket.on(clientEvent: .error) { _, _ in
                    print(".error")
                }
                
                socket.on(clientEvent: .statusChange) { _, _ in
                    print(".statusChange")
                    status = socket.status
                }
                
                socket.on("info") { data, _ in
                    guard let serverInfoDict = data.first,
                          let serverInfoData = try? JSONSerialization.data(withJSONObject: serverInfoDict),
                          let serverInfo = try? JSONDecoder().decode(ServerInfo.self, from: serverInfoData)
                    else {
                        // Throw error message to user
                        print("Error: Could not parse server info")
                        return
                    }
                    
                    withAnimation {
                        setupConfig.serverInfo = serverInfo
                    }
                }
                
                socket.connect(timeoutAfter: 10) {
                    setupConfig.socketManager?.disconnect()
                    setupConfig.socketManager = nil
                    print("timed out")
                }
            }
            .disabled(setupConfig.socketManager != nil)
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
                        // Open Discord authentication flow
                        let supabaseClient = SupabaseClient(
                            supabaseURL: serverInfo.supabaseURL,
                            supabaseKey: serverInfo.supabaseAnonKey,
                            options: .init(auth: .init(emitLocalSessionAsInitialSession: true))
                        )
                        
                        Task {
                            let session = try? await supabaseClient.auth.signInWithOAuth(
                                provider: .discord,
                                redirectTo: URL(string: "avalontrp://setup")
                            )
                            
                            guard let session else {
                                print("Error: Auth session failed")
                                return
                            }
                            
                            socketManager.defaultSocket.disconnect()
                            socketManager.defaultSocket.connect(withPayload: [
                                "access_token": session.accessToken,
                                "refresh_token": session.refreshToken
                            ])
                            
                            withAnimation {
                                setupConfig.supabaseClient = supabaseClient
                            }
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
    
    private var buttonText: String {
        switch status {
        case .notConnected, .disconnected: "Connect"
        case .connecting: "Connecting..."
        case .connected: "Connected!"
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

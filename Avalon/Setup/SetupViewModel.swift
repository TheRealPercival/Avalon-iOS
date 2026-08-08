//
//  SetupViewModel.swift
//  Avalon
//
//  Created by Ben Key on 8/8/26.
//

import SwiftUI
import SocketIO
import Supabase

@Observable
class SetupViewModel {
    private static let customAppSchemeURL: URL? = .init(string: "avalontrp://setup")
    
    var serverURLString: String = ""
    var status: SocketIOStatus = .notConnected
    
    func connectToServer(setupConfig: SetupConfig) {
        guard let serverURL = URL(string: serverURLString) else {
            // Display error to user
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
        
        socket.on(clientEvent: .statusChange) { [weak self] _, _ in
            print(".statusChange")
            self?.status = socket.status
        }
        
        socket.on("info") { data, _ in
            guard let serverInfoDict = data.first,
                  let serverInfoData = try? JSONSerialization.data(withJSONObject: serverInfoDict),
                  let serverInfo = try? JSONDecoder().decode(ServerInfo.self, from: serverInfoData)
            else {
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
    
    @MainActor
    func signIn(setupConfig: SetupConfig, socketManager: SocketManager, serverInfo: ServerInfo) async {
        let supabaseClient = SupabaseClient(
            supabaseURL: serverInfo.supabaseURL,
            supabaseKey: serverInfo.supabaseAnonKey,
            options: .init(auth: .init(emitLocalSessionAsInitialSession: true))
        )
        
        let session = try? await supabaseClient.auth.signInWithOAuth(
            provider: .discord,
            redirectTo: Self.customAppSchemeURL
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
}

extension SetupViewModel {
    var connectButtonText: String {
        switch status {
        case .notConnected, .disconnected: "Connect"
        case .connecting: "Connecting..."
        case .connected: "Connected!"
        }
    }
    
    var isConnectButtonDisabled: Bool {
        switch status {
        case .connecting, .connected: true
        case .notConnected, .disconnected: false
        }
    }
}

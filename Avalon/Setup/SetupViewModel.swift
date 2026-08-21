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
    var serverURLErrorString: String?
    
    func connectToServer(setupConfig: SetupConfig) {
        guard let serverURL else {
            serverURLErrorString = "Invalid URL"
            return
        }
        
        let socketManager = SocketManager(
            socketURL: serverURL,
            config: [.log(true), .compress]
        )
        
        setupConfig.socketManager = socketManager
        
        let socket = socketManager.defaultSocket
        
        socket.once("info") { [weak self] data, _ in
            guard let serverInfoDict = data.first,
                  let serverInfoData = try? JSONSerialization.data(withJSONObject: serverInfoDict),
                  let serverInfo = try? JSONDecoder().decode(ServerInfo.self, from: serverInfoData)
            else {
                self?.serverURLErrorString = "Server info could not be parsed"
                return
            }
            
            withAnimation {
                setupConfig.serverInfo = serverInfo
            }
        }
        
        serverURLErrorString = nil
        socket.connect(timeoutAfter: 5) { [weak self] in
            if let socketManager = setupConfig.socketManager, setupConfig.serverInfo == nil {
                self?.serverURLErrorString = "Could not connect to server"
                
                socketManager.disconnect()
                setupConfig.socketManager = nil
            }
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
    
    func connectButtonText(for status: SocketIOStatus) -> String {
        switch status {
        case .notConnected, .disconnected: "Connect"
        case .connecting: "Connecting..."
        case .connected: "Connected!"
        }
    }
    
    private var serverURL: URL? {
        guard let components = URLComponents(string: serverURLString),
              components.scheme == nil
        else {
            return URL(string: serverURLString)
        }
        
        return URL(string: "https://\(self.serverURLString)")
    }
}

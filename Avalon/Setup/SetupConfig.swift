//
//  SetupConfig.swift
//  Avalon
//
//  Created by Ben Key on 8/8/26.
//

import SwiftUI
import SocketIO
import Supabase

@MainActor
@Observable
class SetupConfig {
    var socketManager: SocketManager? {
        didSet { onSetSocketManager() }
    }
    
    var serverInfo: ServerInfo? {
        didSet { AvalonStorage.shared.serverInfo = serverInfo }
    }
    
    var supabaseClient: SupabaseClient?
    var serverStatus: SocketIOStatus
    
    init(
        socketManager: SocketManager?,
        serverInfo: ServerInfo?,
        supabaseClient: SupabaseClient?
    ) {
        self.socketManager = socketManager
        self.serverInfo = serverInfo
        self.supabaseClient = supabaseClient
        self.serverStatus = socketManager?.status ?? .notConnected
        
        onSetSocketManager()
    }
    
    convenience init() {
        let supabaseClient: SupabaseClient? = {
            guard let serverInfo = AvalonStorage.shared.serverInfo else { return nil }
            
            let supabaseClient = SupabaseClient(
                supabaseURL: serverInfo.supabaseURL,
                supabaseKey: serverInfo.supabaseAnonKey,
                options: .init(auth: .init(emitLocalSessionAsInitialSession: true))
            )
            
            guard supabaseClient.auth.currentSession != nil else { return nil }
            
            return supabaseClient
        }()
        
        self.init(
            socketManager: AvalonStorage.shared.serverURL.map {
                .init(
                    socketURL: $0,
                    config: [.log(true), .compress]
                )
            },
            serverInfo: AvalonStorage.shared.serverInfo,
            supabaseClient: supabaseClient
        )
    }
    
    var complete: CompleteConfig? {
        .init(
            socketManager: socketManager,
            serverInfo: serverInfo,
            supabaseClient: supabaseClient,
            serverStatus: serverStatus,
            onSignOut: signOut,
            onChangeServer: changeServer
        )
    }
    
    public func connectToServer() {
        guard let socketManager, !socketManager.status.active else { return }

        var payload: [String: String]? {
            guard let session = supabaseClient?.auth.currentSession else { return nil }
            
            return [
                "access_token": session.accessToken,
                "refresh_token": session.refreshToken
            ]
        }
        
        print("BLK: setupConfig.connectToServer()")
        socketManager.defaultSocket.connect(withPayload: payload)
    }
    
    private func signOut() async {
        try? await supabaseClient?.auth.signOut()
        supabaseClient = nil
    }
    
    private func changeServer() async {
        await signOut()
        socketManager?.disconnect()
        socketManager = nil
        serverInfo = nil
    }
    
    private func onSetSocketManager() {
        AvalonStorage.shared.serverURL = socketManager?.socketURL
        attachStatusListener()
    }
    
    private func attachStatusListener() {
        guard let socket = socketManager?.defaultSocket else { return }
        
        let statusListenerId = socket.on(clientEvent: .statusChange) { [weak self] _, _ in
            guard let self else {
                socket.off(id: statusListenerId)
                return
            }
            
            self.serverStatus = socket.status
        }
    }
}

extension SetupConfig {
    struct CompleteConfig {
        let socketManager: SocketManager
        let serverInfo: ServerInfo
        let supabaseClient: SupabaseClient
        let serverStatus: SocketIOStatus
        
        private let onSignOut: () async -> Void
        private let onChangeServer: () async -> Void
        
        init?(
            socketManager: SocketManager?,
            serverInfo: ServerInfo?,
            supabaseClient: SupabaseClient?,
            serverStatus: SocketIOStatus,
            onSignOut: @escaping () async -> Void,
            onChangeServer: @escaping () async -> Void
        ) {
            guard let socketManager, let serverInfo, let supabaseClient else { return nil }
            
            self.socketManager = socketManager
            self.serverInfo = serverInfo
            self.supabaseClient = supabaseClient
            self.serverStatus = serverStatus
            self.onSignOut = onSignOut
            self.onChangeServer = onChangeServer
        }
        
        init(
            socketManager: SocketManager,
            serverInfo: ServerInfo,
            supabaseClient: SupabaseClient,
            serverStatus: SocketIOStatus,
            onSignOut: @escaping () async -> Void,
            onChangeServer: @escaping () async -> Void
        ) {
            self.socketManager = socketManager
            self.serverInfo = serverInfo
            self.supabaseClient = supabaseClient
            self.serverStatus = serverStatus
            self.onSignOut = onSignOut
            self.onChangeServer = onChangeServer
        }
        
        var username: String {
            guard let user = supabaseClient.auth.currentUser,
                  let usernameJSON = user.userMetadata["full_name"]
            else {
                return "unknown"
            }
            
            return "@\(usernameJSON.rawValue)"
        }
        
        func signOut() {
            Task { await onSignOut() }
        }
        
        func changeServer() {
            Task { await onChangeServer() }
        }
    }
}

#if DEBUG
extension SetupConfig.CompleteConfig {
    static var preview: Self {
        .init(
            socketManager: .init(
                socketURL: .init(string: "https://server.therealpercival.com")!
            ),
            serverInfo: .init(
                version: "1.0.0",
                supabaseURL: .init(string: "https://therealpercival.supabase.com")!,
                supabaseAnonKey: "abcd1234"
            ),
            supabaseClient: .init(
                supabaseURL: .init(string: "https://therealpercival.supabase.com")!,
                supabaseKey: "abcd1234"
            ),
            serverStatus: .connected,
            onSignOut: {},
            onChangeServer: {}
        )
    }
}
#endif

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
        didSet { attachStatusListener() }
    }
    
    var serverInfo: ServerInfo?
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
    }
    
    convenience init() {
        self.init(
            socketManager: nil,
            serverInfo: nil,
            supabaseClient: nil
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

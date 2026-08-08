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
    var socketManager: SocketManager?
    var serverInfo: ServerInfo?
    var supabaseClient: SupabaseClient?
    
    init(
        socketManager: SocketManager?,
        serverInfo: ServerInfo?,
        supabaseClient: SupabaseClient?
    ) {
        self.socketManager = socketManager
        self.serverInfo = serverInfo
        self.supabaseClient = supabaseClient
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
}

extension SetupConfig {
    struct CompleteConfig {
        var socketManager: SocketManager
        var serverInfo: ServerInfo
        var supabaseClient: SupabaseClient
        private var onSignOut: () async -> Void
        private var onChangeServer: () async -> Void
        
        init?(
            socketManager: SocketManager?,
            serverInfo: ServerInfo?,
            supabaseClient: SupabaseClient?,
            onSignOut: @escaping () async -> Void,
            onChangeServer: @escaping () async -> Void
        ) {
            guard let socketManager, let serverInfo, let supabaseClient else { return nil }
            
            self.socketManager = socketManager
            self.serverInfo = serverInfo
            self.supabaseClient = supabaseClient
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

//
//  SettingsView.swift
//  Avalon
//
//  Created by Ben Key on 7/28/26.
//

import SwiftUI
import SocketIO
import Supabase

struct SettingsView: View {
    @State private var showChangeServerAlert: Bool = false
    @State private var showSignOutAlert: Bool = false
    
    @State private var selectedUsername: String = ""
    
    @State private var showAcceptUserAlert: Bool = false
    @State private var acceptedUserNickname: String = ""
    
    @State private var showRejectUserAlert: Bool = false
    @State private var showRemoveUserAlert: Bool = false
    
    @ScaledMetric private var imageWidth = 32
    
    private let setupConfig: SetupConfig.CompleteConfig
    
    private var isAdmin: Bool
    
    init(
        isAdmin: Bool = false,
        setupConfig: SetupConfig.CompleteConfig
    ) {
        self.isAdmin = isAdmin
        self.setupConfig = setupConfig
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Settings")
                    .foregroundStyle(.primaryText)
                    .font(.livvic(size: .subheading))
                
                if isAdmin {
                    adminSettingsView
                }
                
                makeSection(title: "Server") {
                    HStack {
                        Text(setupConfig.socketManager.socketURL.hostString)
                            .foregroundStyle(.primaryText)
                            .font(.livvic)
                        
                        Spacer()
                        
                        serverStatusIcon
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .overlay {
                        RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(.tertiaryText)
                    }
                    
                    AvalonButton("Change Server", isDestructive: true) {
                        showChangeServerAlert = true
                    }
                    .alert(
                        "Are you sure?",
                        isPresented: $showChangeServerAlert
                    ) {
                        Button("Cancel", role: .cancel) {}
                        Button("Yes", role: .destructive) {
                            setupConfig.changeServer()
                        }
                    } message: {
                        Text("Changing your current server will also sign you out.")
                    }
                }
                
                makeSection(title: "Account") {
                    HStack {
                        Text("Ben (hardcoded)")
                            .foregroundStyle(.primaryText)
                            .font(.livvic)
                        
                        Spacer()
                        
                        Text(setupConfig.username)
                            .foregroundStyle(.tertiaryText)
                            .font(.livvic)
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .overlay {
                        RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(.tertiaryText)
                    }
                    
                    AvalonButton("Sign Out", isDestructive: true) {
                        showSignOutAlert = true
                    }
                    .alert(
                        "Are you sure?",
                        isPresented: $showSignOutAlert
                    ) {
                        Button("Cancel", role: .cancel) {}
                        Button("Yes", role: .destructive) {
                            setupConfig.signOut()
                        }
                    } message: {
                        Text("Do you really want to sign out?")
                    }
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity)
        }
        .scrollBounceBehavior(.basedOnSize)
        .background {
            Color.fullBackground
                .ignoresSafeArea()
        }
    }
    
    @ViewBuilder
    private var adminSettingsView: some View {
        makeSection(title: "Requests") {
            makeUserRow(color: .red1, primaryText: "@ben.json", canAccept: true)
            makeUserRow(color: .green1, primaryText: "@65472624657", canAccept: true)
            makeUserRow(color: .blue1, primaryText: "@_shoe_", canAccept: true)
        }
        .alert("Nickname", isPresented: $showAcceptUserAlert) {
            TextField("Nickname", text: $acceptedUserNickname)
            
            Button("Cancel", role: .cancel) {
                acceptedUserNickname = ""
            }
            
            Button("Accept") {
                acceptedUserNickname = ""
            }
            .keyboardShortcut(.defaultAction)
        } message: {
            Text("Assign \(selectedUsername) a nickname:")
        }
        .alert("Are you sure?", isPresented: $showRejectUserAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Reject", role: .destructive) {}
        } message: {
            Text("Do you want to reject \(selectedUsername) from joining the server?")
        }
        .alert("Are you sure?", isPresented: $showRemoveUserAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Remove", role: .destructive) {}
        } message: {
            Text("Do you want to remove \(selectedUsername) from the server?")
        }


        makeSection(title: "Accepted") {
            makeUserRow(color: .red1, primaryText: "Ben", secondaryText: "@ben.json")
            makeUserRow(color: .green1, primaryText: "Drew", secondaryText: "@65472624657")
            makeUserRow(color: .blue1, primaryText: "Thomas", secondaryText: "@_shoe_")
        }
    }
    
    private var serverStatusIcon: some View {
        let isConnected = setupConfig.serverStatus == .connected
        return Image(systemName: isConnected ? "checkmark" : "xmark")
            .foregroundStyle(isConnected ? .green2 : .red1)
            .font(.livvic)
    }
    
    private func makeSection(title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .foregroundStyle(.secondaryText)
                .font(.livvic(size: .note))
            
            content()
        }
        .frame(maxWidth: .infinity)
    }
    
    private func makeUserRow(
        color: Color,
        primaryText: String,
        secondaryText: String? = nil,
        canAccept: Bool = false
    ) -> some View {
        HStack(spacing: 8) {
            color
                .clipShape(.circle)
                .frame(width: imageWidth, height: imageWidth)
            
            Text(primaryText)
                .foregroundStyle(.primaryText)
                .font(.livvic)
            
            if let secondaryText {
                Text(secondaryText)
                    .foregroundStyle(.tertiaryText)
                    .font(.livvic)
            }
            
            Spacer()
            
            HStack(spacing: 16) {
                if canAccept {
                    Button {
                        // Allow user in
                        selectedUsername = primaryText
                        showAcceptUserAlert = true
                    } label: {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green2)
                            .font(.livvic)
                    }
                }
                
                Button {
                    // Remove user
                    if let secondaryText {
                        selectedUsername = "\(primaryText) (\(secondaryText))"
                        showRemoveUserAlert = true
                    } else {
                        selectedUsername = primaryText
                        showRejectUserAlert = true
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.red1)
                        .font(.livvic)
                }
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .overlay {
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(.tertiaryText)
        }
    }
}

#Preview("Default Settings") {
//    SettingsView()
}

#Preview("Admin Settings") {
//    SettingsView(isAdmin: true)
}

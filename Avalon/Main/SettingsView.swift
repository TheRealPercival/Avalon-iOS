//
//  SettingsView.swift
//  Avalon
//
//  Created by Ben Key on 7/28/26.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Settings")
                    .foregroundStyle(.primaryText)
                    .font(.livvic(size: .subheading))
                
                adminSettingsView
                
                makeSection(title: "Server") {
                    HStack {
                        Text("server.therealpercival.com")
                            .foregroundStyle(.primaryText)
                            .font(.livvic)
                        
                        Spacer()
                        
                        Image(systemName: "checkmark")
                            .foregroundStyle(.green2)
                            .font(.livvic)
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .overlay {
                        RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(.tertiaryText)
                    }
                    
                    AvalonButton("Change Server", isDestructive: true) {
                        // Go back to setup screen
                    }
                }
                
                makeSection(title: "Account") {
                    HStack {
                        Text("Ben")
                            .foregroundStyle(.primaryText)
                            .font(.livvic)
                        
                        Spacer()
                        
                        Text("@ben.json")
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
                        // Go back to setup screen
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
        
        makeSection(title: "Accepted") {
            makeUserRow(color: .red1, primaryText: "Ben", secondaryText: "@ben.json")
            makeUserRow(color: .green1, primaryText: "Drew", secondaryText: "@65472624657")
            makeUserRow(color: .blue1, primaryText: "Thomas", secondaryText: "@_shoe_")
        }
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
                .frame(width: 32, height: 32)
                .clipShape(.circle)
            
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
                    } label: {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green2)
                            .font(.livvic)
                    }
                }
                
                Button {
                    // Remove user
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

#Preview {
    SettingsView()
}

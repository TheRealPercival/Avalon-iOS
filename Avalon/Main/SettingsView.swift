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
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Server")
                        .foregroundStyle(.secondaryText)
                        .font(.livvic(size: .note))
                    
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
                .frame(maxWidth: .infinity)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Account")
                        .font(.livvic(size: .note))
                        .foregroundStyle(.secondaryText)
                    
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
                .frame(maxWidth: .infinity)
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
}

#Preview {
    SettingsView()
}

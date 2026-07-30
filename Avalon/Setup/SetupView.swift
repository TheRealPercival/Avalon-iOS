//
//  SetupView.swift
//  Avalon
//
//  Created by Ben Key on 7/24/26.
//

import SwiftUI

struct SetupView: View {
    @ScaledMetric private var logoHeight = 18
    
    @State private var serverURLString: String = ""
    @State private var isServerURLValid: Bool = false
    
    @Binding private var isSetupComplete: Bool
    
    init(isSetupComplete: Binding<Bool>) {
        self._isSetupComplete = isSetupComplete
    }
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 0) {
                    AvalonHeader()
                    
                    if isServerURLValid {
                        signInView
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
    
    var serverURLView: some View {
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
                .overlay {
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(.tertiaryText)
                }
            }
            
            Spacer()
            
            AvalonButton("Connect") {
                // Connect to WebSocket server to verify
                withAnimation {
                    isServerURLValid = true
                }
            }
        }
    }
    
    var signInView: some View {
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
                        isSetupComplete = true
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
                    
                    Text("Connected to \(serverURLString)")
                        .font(.livvic(size: .note))
                        .foregroundStyle(.tertiaryText)
                }
            }
            .multilineTextAlignment(.center)
            
            Spacer()
        }
    }
}

#Preview {
    SetupView(isSetupComplete: .constant(false))
}

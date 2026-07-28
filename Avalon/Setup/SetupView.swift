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
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 0) {
                    HStack(spacing: 12) {
                        Image(.merlinCutout)
                            .resizable()
                            .frame(maxWidth: 81, maxHeight: 60)
                        
                        VStack(alignment: .leading, spacing: -10) {
                            Text("Avalon")
                                .foregroundStyle(.white1)
                                .font(.livvic(size: 50, weight: .medium))
                            
                            Text("The Real Percival")
                                .foregroundStyle(.gray0)
                                .font(.livvic(size: 16, weight: .regular, italic: true))
                        }
                        .padding(.top, -6)
                    }
                    
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
                Color.gray4
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
                        .foregroundStyle(.white1)
                        .font(.livvic(size: .subheading))
                    
                    Text("Welcome to an online adaptation of Don Eskridge's Avalon: Big Box Edition. Please enter your group's server URL below to begin.")
                        .foregroundStyle(.gray0)
                        .font(.livvic(size: .note))
                }
                .multilineTextAlignment(.center)
                
                TextField(
                    "Server URL",
                    text: $serverURLString,
                    prompt: Text("Server URL").foregroundStyle(.gray3)
                )
                .keyboardType(.URL)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .foregroundStyle(.white1)
                .font(.livvic)
                .padding(12)
                .overlay {
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(.gray2)
                }
            }
            
            Spacer()
            
            Button {
                // Connect to WebSocket server to verify
                withAnimation {
                    isServerURLValid = true
                }
            } label: {
                Text("Connect")
                    .foregroundStyle(.white1)
                    .font(.livvic(weight: .medium))
                    .padding(12)
                    .frame(maxWidth: .infinity)
                    .background(.blue1)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
    }
    
    var signInView: some View {
        VStack(spacing: 0) {
            Spacer()
            
            VStack(spacing: 48) {
                VStack(spacing: 12) {
                    Text("Identify yourself!")
                        .foregroundStyle(.white1)
                        .font(.livvic(size: .subheading))
                    
                    Text("Sign into your Discord account below so your game history can be saved.")
                        .foregroundStyle(.gray0)
                        .font(.livvic(size: .note))
                }
                
                VStack(spacing: 8) {
                    Button {
                        // Open Discord authentication flow
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
                        .foregroundStyle(.gray2)
                }
            }
            .multilineTextAlignment(.center)
            
            Spacer()
        }
    }
}

#Preview {
    SetupView()
}

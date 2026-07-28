//
//  SetupView.swift
//  Avalon
//
//  Created by Ben Key on 7/24/26.
//

import SwiftUI

struct SetupView: View {
    @State private var serverURLString: String = ""
    
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
                                .stroke()
                                .foregroundStyle(.gray2)
                        }
                    }
                    
                    Spacer()
                    
                    Button {
                        // Connect to WebSocket server to verify
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
}

#Preview {
    SetupView()
}

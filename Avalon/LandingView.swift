//
//  LandingView.swift
//  Avalon
//
//  Created by Ben Key on 7/24/26.
//

import SwiftUI

struct LandingView: View {
    @State private var serverURLString: String = ""
    @State private var isConnecting: Bool = false
    
    @State private var loadingAngle: Double = 0
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image(.merlinCutout)
                    .resizable()
                    .frame(maxWidth: 81, maxHeight: 60)
                
                VStack(alignment: .leading, spacing: -10) {
                    Text("Avalon")
                        .foregroundStyle(.white1)
                        .font(.system(size: 50))
                        .fontWeight(.semibold)
                    
                    Text("The Real Percival")
                        .foregroundStyle(.gray0)
                        .italic()
                }
                .padding(.top, -6)
            }
            
            Spacer()
            
            VStack(spacing: 48) {
                VStack(spacing: 12) {
                    Text("You've arrived in Avalon!")
                        .foregroundStyle(.white1)
                        .font(.system(size: 26))
                        .fontWeight(.medium)
                    
                    Text("Welcome to an online adaptation of Don Eskridge's Avalon: Big Box Edition. Please enter your group's server URL below to begin.")
                        .foregroundStyle(.gray0)
                        .multilineTextAlignment(.center)
                        .font(.system(size: 14))
                }
                
                TextField(
                    "Server URL",
                    text: $serverURLString,
                    prompt: Text("Server URL").foregroundStyle(.gray3)
                )
                .disabled(isConnecting)
                .opacity(isConnecting ? 0.35 : 1)
                .keyboardType(.URL)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .foregroundStyle(.white1)
                .font(.system(size: 18))
                .padding(12)
                .overlay {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke()
                        .foregroundStyle(.gray2)
                }
            }
            
            Spacer()
            
            let isDisabled = serverURLString.isEmpty || isConnecting
            Button {
                Task {
                    isConnecting = true
                    try? await Task.sleep(for: .seconds(5))
                    isConnecting = false
                }
            } label: {
                HStack {
                    if isConnecting {
                        Image(systemName: "progress.indicator")
                            .rotationEffect(.degrees(loadingAngle))
                            .onAppear {
                                withAnimation(
                                    .linear
                                        .speed(0.2)
                                        .repeatForever(autoreverses: false)
                                ) {
                                    loadingAngle = 360
                                }
                            }
                            .onDisappear {
                                loadingAngle = 0
                            }
                    }
                    
                    Text(isConnecting ? "Connecting" : "Connect")
                }
                .foregroundStyle(.white1)
                .font(.system(size: 18))
                .fontWeight(.medium)
                .padding(12)
                .frame(maxWidth: .infinity)
                .background(.blue1)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .disabled(isDisabled)
            .opacity(isDisabled ? 0.35 : 1)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .background {
            Color.gray4
                .ignoresSafeArea()
        }
    }
}

#Preview {
    LandingView()
}

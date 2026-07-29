//
//  JoinView.swift
//  Avalon
//
//  Created by Ben Key on 7/29/26.
//

import SwiftUI

struct JoinView: View {
    private var joinMessage: String = "Join Game (5 in lobby)"
    private var spectateGameMessage: String = "Spectate (5 in game)"
    private var spectateLobbyMessage: String = "Spectate (lobby full)"
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 0) {
                    AvalonHeader()
                    
                    Spacer()
                    
                    AvalonButton(joinMessage) {
                        // Go to game screen
                    } trailingView: {
                        StackedProfilePictures {
                            Color.red1
                            Color.green1
                            Color.blue2
                        }
                    }
                    
                    Spacer()
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
}

#Preview {
    JoinView()
}

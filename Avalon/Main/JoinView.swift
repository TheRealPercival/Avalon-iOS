//
//  JoinView.swift
//  Avalon
//
//  Created by Ben Key on 7/29/26.
//

import SwiftUI

struct JoinView: View {
    private let joinType: JoinType
    
    init(joinType: JoinType = .joinGame) {
        self.joinType = joinType
    }
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 0) {
                    AvalonHeader()
                    
                    Spacer()
                    
                    AvalonButton(joinType.message) {
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
    
extension JoinView {
    enum JoinType {
        case joinGame
        case spectateGame
        case spectateLobby
        
        var message: String {
            switch self {
            case .joinGame: "Join Game (5 in lobby)"
            case .spectateGame: "Spectate (5 in game)"
            case .spectateLobby: "Spectate (lobby full)"
            }
        }
    }
}

#Preview("Join Game") {
    JoinView(joinType: .joinGame)
}

#Preview("Spectate Game") {
    JoinView(joinType: .spectateGame)
}

#Preview("Spectate Lobby") {
    JoinView(joinType: .spectateLobby)
}

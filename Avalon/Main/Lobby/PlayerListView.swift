//
//  PlayerListView.swift
//  Avalon
//
//  Created by Ben Key on 9/7/26.
//

import SwiftUI

struct PlayerListView: View {
    @ScaledMetric private var listIconWidth = 32
    
    @State private var selectedPlayer: UIColor?
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Joined Players")
                    .font(.livvic(size: .subheading))
                
                ForEach(LobbyViewModel.mockGridColors, id: \.self) { color in
                    let isSelected = selectedPlayer == color
                    let rowShape = RoundedRectangle(cornerRadius: 10)
                    
                    HStack {
                        Color(color)
                            .aspectRatio(contentMode: .fill)
                            .frame(width: listIconWidth)
                            .clipShape(.circle)
                        
                        Text(color.accessibilityName.capitalized)
                            .foregroundStyle(isSelected ? .white1 : .primaryText)
                            .font(.livvic)
                        
                        Spacer()
                        
                        if color == LobbyViewModel.mockGridColors.first {
                            Text("(you)")
                                .foregroundStyle(isSelected ? .white1 : .tertiaryText)
                                .font(.livvic(size: .note))
                        }
                    }
                    .padding(12)
                    .contentShape(rowShape)
                    .background {
                        rowShape
                            .fill(isSelected ? .blue1 : .clear)
                    }
                    .overlay {
                        if !isSelected {
                            rowShape
                                .strokeBorder(.tertiaryText)
                        }
                    }
                    .onTapGesture {
                        if isSelected {
                            selectedPlayer = .none
                        } else {
                            selectedPlayer = color
                        }
                    }
                }
                
                Spacer()
            }
            .padding(16)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        }
        .scrollBounceBehavior(.basedOnSize)
        .safeAreaInset(edge: .bottom) {
            if selectedPlayer != nil {
                HStack(spacing: 16) {
                    AvalonButton("Make Host") {
                        // Request reveal stage
                    }
                    
                    AvalonButton("Kick", isDestructive: true) {
                        // Request reveal stage
                    }
                }
                .padding(.horizontal, 16)
            }
        }
        .background {
            Color.fullBackground
                .ignoresSafeArea()
        }
    }
}

#Preview {
    PlayerListView()
}

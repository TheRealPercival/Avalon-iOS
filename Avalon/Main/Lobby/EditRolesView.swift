//
//  EditRolesView.swift
//  Avalon
//
//  Created by Ben Key on 9/7/26.
//

import SwiftUI

struct EditRolesView: View {
    @Environment(\.dismiss) private var dismiss
    
    @Namespace private var viewSpace
    
    @ScaledMetric private var minCellWidth = 50
    @ScaledMetric private var maxCellWidth = 80
    
    @State private var selectedAssassin: String
    @State private var focusedCard: UIColor?
    
    init() {
        selectedAssassin = LobbyViewModel.mockAssassinRoles.first ?? "Morgana"
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Edit Roles")
                    .font(.livvic(size: .subheading))
                
                makeTeamSection("Good Team", roles: LobbyViewModel.mockGridColors.prefix(6))
                
                makeTeamSection("Evil Team", roles: LobbyViewModel.mockGridColors.suffix(4))
                
                AvalonSection("Assassin") {
                    AvalonMenu(
                        selection: $selectedAssassin,
                        options: LobbyViewModel.mockAssassinRoles,
                        label: { $0 }
                    )
                }
                
                Spacer()
            }
            .padding(16)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        }
        .scrollBounceBehavior(.basedOnSize)
        .safeAreaInset(edge: .bottom) {
            AvalonButton("Save") {
                // Save role choices
                dismiss()
            }
            .padding(.horizontal, 16)
        }
        .background {
            Color.fullBackground
                .ignoresSafeArea()
        }
        .overlay {
            if let focusedCard {
                Color.black
                    .ignoresSafeArea()
                    .opacity(0.5)
                    .overlay {
                        VStack {
                            Color(focusedCard)
                                .aspectRatio(1 / 1.4, contentMode: .fit)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .matchedGeometryEffect(id: focusedCard, in: viewSpace)
                                .transition(.scale(scale: 1.0))
                        }
                        .padding(32)
                    }
                    .onTapGesture {
                        withAnimation(Self.cardAnimation) {
                            self.focusedCard = .none
                        }
                    }
            }
        }
    }
}

extension EditRolesView {
    private static let cardAnimation: Animation = .spring(
        duration: 0.2,
        blendDuration: 2
    )
    
    private func makeTeamSection(_ title: String, roles: Array<UIColor>.SubSequence) -> some View {
        AvalonSection(title) {
            makeGrid {
                ForEach(roles, id: \.self) { color in
                    Color(color)
                        .aspectRatio(contentMode: .fill)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(roles, id: \.self) { color in
                        Color(color)
                            .aspectRatio(1 / 1.4, contentMode: .fill)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .frame(maxWidth: .infinity)
                            .matchedGeometryEffect(id: color, in: viewSpace)
                            .transition(.scale(scale: 1.0))
                            .onLongPressGesture {
                                withAnimation(Self.cardAnimation) {
                                    focusedCard = color
                                }
                            }
                    }
                }
                .frame(height: 190)
                .padding(.horizontal, 16)
            }
            .padding(.horizontal, -16)
        }
    }
    
    private func makeGrid(with content: () -> some View) -> some View {
        LazyVGrid(
            columns: [.init(.adaptive(
                minimum: minCellWidth,
                maximum: maxCellWidth
            ))],
            content: content
        )
    }
}

#Preview {
    EditRolesView()
}

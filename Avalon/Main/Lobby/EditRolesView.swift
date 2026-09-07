//
//  EditRolesView.swift
//  Avalon
//
//  Created by Ben Key on 9/7/26.
//

import SwiftUI

struct EditRolesView: View {
    @Environment(\.dismiss) private var dismiss
    
    @ScaledMetric private var minCellWidth = 50
    @ScaledMetric private var maxCellWidth = 80
    
    @State private var selectedAssassin: String
    
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
    }
}

extension EditRolesView {
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

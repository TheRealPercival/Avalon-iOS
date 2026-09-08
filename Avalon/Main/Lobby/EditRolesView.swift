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
    @State private var focusedRole: MockRole?
    
    init() {
        selectedAssassin = LobbyViewModel.mockAssassinRoles.first ?? "Morgana"
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Edit Roles")
                    .font(.livvic(size: .subheading))
                
                makeTeamSection("Good Team", roles: LobbyViewModel.mockGoodRoles)
                
                makeTeamSection("Evil Team", roles: LobbyViewModel.mockEvilRoles)
                
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
            if let focusedRole {
                Color.black
                    .ignoresSafeArea()
                    .opacity(0.5)
                    .overlay {
                        VStack {
                            Image(uiImage: focusedRole.cardImage)
                                .resizable()
                                .scaledToFit()
                                .matchedGeometryEffect(id: focusedRole.id, in: viewSpace)
                                .transition(.scale(scale: 1.0))
                                .dragRotation3D()
                        }
                        .padding(32)
                    }
                    .onTapGesture {
                        withAnimation(Self.cardAnimation) {
                            self.focusedRole = .none
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
    
    private func makeTeamSection(_ title: String, roles: [MockRole]) -> some View {
        AvalonSection(title) {
            makeGrid {
                ForEach(roles) { role in
                    Image(uiImage: role.iconImage)
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(roles) { role in
                        Image(uiImage: role.cardImage)
                            .resizable()
                            .scaledToFit()
                            .matchedGeometryEffect(id: role.id, in: viewSpace)
                            .opacity(focusedRole?.id == role.id ? 0 : 1)
                            .transition(.scale(scale: 1.0))
                            .onLongPressGesture {
                                withAnimation(Self.cardAnimation) {
                                    focusedRole = role
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

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
    
    @Binding var selectedGoodRoles: [MockRole]
    @Binding var selectedEvilRoles: [MockRole]
    
    @State var draftGoodRoles: [MockRole]
    @State var draftEvilRoles: [MockRole]
    
    @State private var selectedAssassin: String
    @State private var focusedRole: MockRole?
    
    init(selectedGoodRoles: Binding<[MockRole]>, selectedEvilRoles: Binding<[MockRole]>) {
        self._selectedGoodRoles = selectedGoodRoles
        self._selectedEvilRoles = selectedEvilRoles
        self.draftGoodRoles = selectedGoodRoles.wrappedValue
        self.draftEvilRoles = selectedEvilRoles.wrappedValue
        selectedAssassin = LobbyViewModel.mockAssassinRoles.first ?? "Morgana"
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Edit Roles")
                    .font(.livvic(size: .subheading))
                
                makeTeamSection(
                    "Good Team",
                    max: 6,
                    selectedRoles: $draftGoodRoles,
                    allRoles: LobbyViewModel.mockGoodRoles
                )
                
                makeTeamSection(
                    "Evil Team",
                    max: 4,
                    selectedRoles: $draftEvilRoles,
                    allRoles: LobbyViewModel.mockEvilRoles
                )
                
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
            Group {
                if hasUnsavedChanges {
                    AvalonButton("Save") {
                        // Save role choices
                        selectedGoodRoles = draftGoodRoles
                        selectedEvilRoles = draftEvilRoles
                        dismiss()
                    }
                    .padding(.horizontal, 16)
                }
            }
            .inanimate()
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
    
    private func makeTeamSection(
        _ title: String,
        max: Int,
        selectedRoles: Binding<[MockRole]>,
        allRoles: [MockRole]
    ) -> some View {
        AvalonSection(title) {
            makeGrid {
                Group {
                    let roles = Array(selectedRoles.wrappedValue.enumerated())
                    
                    ForEach(roles, id: \.element.id) { offset, role in
                        Image(uiImage: role.iconImage)
                            .resizable()
                            .scaledToFit()
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    
                    let missingCount = max - selectedRoles.wrappedValue.count
                    let range: Range<Int> = 0..<missingCount
                    
                    ForEach(range.reversed(), id: \.self) { index in
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(style: .init(lineWidth: 2, dash: [6,6]))
                            .aspectRatio(contentMode: .fit)
                            .overlay {
                                Image(systemName: "plus")
                                    .font(.livvic)
                            }
                            .foregroundStyle(.subtleText)
                    }
                }
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(allRoles) { role in
                        let isSelected = selectedRoles.contains { $0.id == role.id }
                        let opacity = focusedRole?.id == role.id ? 0 : isSelected ? 0.4 : 1
                        
                        Image(uiImage: role.cardImage)
                            .resizable()
                            .scaledToFit()
                            .matchedGeometryEffect(id: role.id, in: viewSpace)
                            .opacity(opacity)
                            .transition(.scale(scale: 1.0))
                            .onLongPressGesture {
                                withAnimation(Self.cardAnimation) {
                                    focusedRole = role
                                }
                            }
                            .onTapGesture {
                                withAnimation {
                                    if isSelected {
                                        selectedRoles.wrappedValue.removeAll { $0.id == role.id }
                                    } else {
                                        let newSet = selectedRoles.wrappedValue + [role]
                                        selectedRoles.wrappedValue = allRoles.filter { allRole in
                                            newSet.contains { $0.id == allRole.id }
                                        }
                                    }
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
    
    private var hasUnsavedChanges: Bool {
        !(selectedGoodRoles == draftGoodRoles && selectedEvilRoles == draftEvilRoles)
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
    @Previewable @State var selectedGoodRoles: [MockRole] = .init()
    @Previewable @State var selectedEvilRoles: [MockRole] = .init()
    
    EditRolesView(
        selectedGoodRoles: $selectedGoodRoles,
        selectedEvilRoles: $selectedEvilRoles
    )
}

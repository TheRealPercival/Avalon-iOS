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
    
    @Binding private var selectedGoodRoles: [MockRole]
    @Binding private var selectedEvilRoles: [MockRole]
    @Binding private var selectedAssassin: MockRole?
    
    @State private var draftGoodRoles: [MockRole]
    @State private var draftEvilRoles: [MockRole]
    @State private var draftAssassin: MockRole?
    
    @State private var focusedRole: MockRole?
    
    init(
        selectedGoodRoles: Binding<[MockRole]>,
        selectedEvilRoles: Binding<[MockRole]>,
        selectedAssassin: Binding<MockRole?>
    ) {
        self._selectedGoodRoles = selectedGoodRoles
        self._selectedEvilRoles = selectedEvilRoles
        self._selectedAssassin = selectedAssassin
        
        self._draftGoodRoles = State(initialValue: selectedGoodRoles.wrappedValue)
        self._draftEvilRoles = State(initialValue: selectedEvilRoles.wrappedValue)
        self._draftAssassin = State(initialValue: selectedAssassin.wrappedValue)
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
                        selection: $draftAssassin,
                        options: [.none] + draftEvilRoles,
                        label: { $0?.name ?? "None" }
                    )
                }
                .onChange(of: draftEvilRoles) {
                    let isContained = draftEvilRoles.contains { $0 == draftAssassin }
                    guard !isContained else { return }
                    
                    draftAssassin = .none
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
                        selectedAssassin = draftAssassin
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
                    ForEach(selectedRoles.wrappedValue) { role in
                        Image(uiImage: role.iconImage)
                            .resizable()
                            .scaledToFit()
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .overlay {
                                if role == draftAssassin {
                                    VStack(alignment: .leading) {
                                        Text("🗡️")
                                            .offset(x: -6, y: -6)
                                            .shadow(radius: 5)
                                    }
                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                                }
                            }
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
        selectedGoodRoles != draftGoodRoles ||
        selectedEvilRoles != draftEvilRoles ||
        selectedAssassin != draftAssassin
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
    EditRolesView(
        selectedGoodRoles: .constant(.init()),
        selectedEvilRoles: .constant(.init()),
        selectedAssassin: .constant(.none)
    )
}

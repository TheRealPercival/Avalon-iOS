//
//  LobbyView.swift
//  Avalon
//
//  Created by Ben Key on 9/6/26.
//

import SwiftUI
import SocketIO

struct LobbyView: View {
    @Environment(\.dismiss) private var dismiss
    
    @ScaledMetric private var listIconWidth = 32
    @ScaledMetric private var minSmallCellWidth = 50
    @ScaledMetric private var minCellWidth = 60
    @ScaledMetric private var maxCellWidth = 80
    
    @State private var viewModel: LobbyViewModel = .init()
    
    private let setupConfig: SetupConfig.CompleteConfig
    
    init(setupConfig: SetupConfig.CompleteConfig) {
        self.setupConfig = setupConfig
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                presetSection
                rolesSection
                settingsSection
                playersSection
            }
            .padding(16)
            .frame(maxWidth: .infinity)
        }
        .safeAreaInset(edge: .bottom) {
            AvalonButton("Start") {
                // Request reveal stage
            }
            .padding(.horizontal, 16)
        }
        .scrollBounceBehavior(.basedOnSize)
        .navigationBarBackButtonHidden()
        .background {
            Color.fullBackground
                .ignoresSafeArea()
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                backButton
            }
            
            ToolbarItem(placement: .title) {
                Text("Lobby")
                    .font(.livvic(size: .subheading))
            }
        }
    }
}

extension LobbyView {
    private var presetSection: some View {
        AvalonSection("Preset") {
            Menu {
                Picker("Preset", selection: $viewModel.selectedPreset) {
                    ForEach(LobbyViewModel.mockPresets, id: \.self) { preset in
                        Text(preset)
                    }
                }
            } label: {
                HStack {
                    Text(viewModel.selectedPreset)
                    Spacer()
                    Image(systemName: "chevron.up.chevron.down")
                }
                .foregroundStyle(.primaryText)
                .font(.livvic)
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .overlay {
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(.tertiaryText)
            }
        }
    }
    
    private var rolesSection: some View {
        AvalonSection("Roles") {
            makeGrid {
                ForEach(LobbyViewModel.mockGridColors, id: \.self) { color in
                    Color(color)
                        .aspectRatio(contentMode: .fill)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
        }
        .onTapGesture {
            viewModel.isEditRolesOpen = true
        }
        .sheet(isPresented: $viewModel.isEditRolesOpen) {
            editRolesList
        }
    }
    
    private var editRolesList: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Edit Roles")
                    .font(.livvic(size: .subheading))
                
                AvalonSection("Good Team") {
                    let goodRoles = LobbyViewModel.mockGridColors.prefix(6)
                    
                    makeGrid(isSmall: true) {
                        ForEach(goodRoles, id: \.self) { color in
                            Color(color)
                                .aspectRatio(contentMode: .fill)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(goodRoles, id: \.self) { color in
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
                
                AvalonSection("Evil Team") {
                    let evilRoles = LobbyViewModel.mockGridColors.suffix(4)
                    
                    makeGrid(isSmall: true) {
                        ForEach(evilRoles, id: \.self) { color in
                            Color(color)
                                .aspectRatio(contentMode: .fill)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(evilRoles, id: \.self) { color in
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
                
                Spacer()
            }
            .padding(16)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        }
        .scrollBounceBehavior(.basedOnSize)
        .safeAreaInset(edge: .bottom) {
            AvalonButton("Save") {
                // Save role choices
                viewModel.isEditRolesOpen = false
            }
            .padding(.horizontal, 16)
        }
        .background {
            Color.fullBackground
                .ignoresSafeArea()
        }
    }
    
    private var settingsSection: some View {
        AvalonSection("Settings") {
            makeGrid {
                Group {
                    makeToggleButton(rule: $viewModel.isTrapperEnabled) {
                        Image(systemName: "lock.fill")
                            .foregroundStyle(.white1)
                            .font(.livvic(size: .heading, weight: .regular))
                    }
                    
                    makeToggleButton(rule: $viewModel.isLadyEnabled) {
                        Image(systemName: "figure.stand.dress")
                            .foregroundStyle(.white1)
                            .font(.livvic(size: .heading, weight: .regular))
                    }
                    
                    makeToggleButton(rule: $viewModel.isFailResetEnabled) {
                        Image(systemName: "arrow.circlepath")
                            .foregroundStyle(.white1)
                            .rotationEffect(.degrees(90))
                            .font(.livvic(size: .heading, weight: .regular))
                            .overlay {
                                Image(systemName: "hand.thumbsdown.fill")
                                    .foregroundStyle(.white1)
                                    .font(.livvic(size: 20, weight: .regular))
                                    .offset(y: 1)
                            }
                    }
                }
            }
        }
    }
    
    private var playersSection: some View {
        AvalonSection("Players") {
            makeGrid {
                ForEach(LobbyViewModel.mockGridColors, id: \.self) { color in
                    VStack(spacing: 4) {
                        Color(color)
                            .aspectRatio(contentMode: .fill)
                            .clipShape(.circle)
                        
                        VStack {
                            Text(" ")
                                .foregroundStyle(.clear)
                                .font(.livvic(size: .note))
                                .lineLimit(1)
                                .accessibilityHidden(true)
                        }
                        .frame(maxWidth: .infinity)
                        .overlay {
                            Text(color.accessibilityName.capitalized)
                                .foregroundStyle(.secondaryText)
                                .font(.livvic(size: .note))
                                .lineLimit(1)
                                .truncationMode(.middle)
                                .minimumScaleFactor(0.5)
                        }
                    }
                    .onTapGesture {
                        viewModel.selectedPlayer = color
                        viewModel.isPlayerListOpen = true
                    }
                }
            }
        }
        .onTapGesture {
            viewModel.isPlayerListOpen = true
        }
        .sheet(isPresented: $viewModel.isPlayerListOpen) {
            viewModel.selectedPlayer = nil
        } content: {
            playersList
        }
    }
    
    private var playersList: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Joined Players")
                    .font(.livvic(size: .subheading))
                
                ForEach(LobbyViewModel.mockGridColors, id: \.self) { color in
                    let isSelected = viewModel.selectedPlayer == color
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
                            viewModel.selectedPlayer = nil
                        } else {
                            viewModel.selectedPlayer = color
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
            if viewModel.selectedPlayer != nil {
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
    
    private func makeGrid(isSmall: Bool = false, with content: () -> some View) -> some View {
        LazyVGrid(
            columns: [.init(.adaptive(
                minimum: isSmall ? minSmallCellWidth : minCellWidth,
                maximum: maxCellWidth
            ))],
            content: content
        )
    }
    
    private func makeToggleButton(rule: Binding<Bool>, icon: () -> some View) -> some View {
        Button {
            rule.wrappedValue.toggle()
        } label: {
            Color(rule.wrappedValue ? .blue1 : .subtleText)
                .animation(.none)
                .aspectRatio(contentMode: .fill)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(content: icon)
        }
    }
    
    private var backButton: some View {
        Button("Back", systemImage: "chevron.left") {
            viewModel.isRequestingToLeave = true
        }
        .tint(.primaryText)
        .confirmationDialog(
            "Are you sure?",
            isPresented: $viewModel.isRequestingToLeave,
            titleVisibility: .visible
        ) {
            Button("Leave", role: .destructive) {
                viewModel.requestToLeaveSession(for: socket) {
                    dismiss()
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Do you really want to leave the session?")
        }
    }
    
    private var socket: SocketIOClient {
        setupConfig.socketManager.defaultSocket
    }
}

#Preview {
    LobbyView(setupConfig: .preview)
}

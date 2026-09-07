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
            AvalonMenu(
                selection: $viewModel.selectedPreset,
                options: LobbyViewModel.mockPresets,
                label: { $0 }
            )
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
            EditRolesView()
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
                }
            }
        }
        .onTapGesture {
            viewModel.isPlayerListOpen = true
        }
        .sheet(isPresented: $viewModel.isPlayerListOpen) {
            PlayerListView()
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

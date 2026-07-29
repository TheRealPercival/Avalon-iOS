//
//  AvalonButton.swift
//  Avalon
//
//  Created by Ben Key on 7/28/26.
//

import SwiftUI

struct AvalonButton<Content: View>: View {
    private let label: String
    private let isDestructive: Bool
    private let action: () -> Void
    private let trailingView: () -> Content
    
    init(
        _ label: String,
        isDestructive: Bool = false,
        action: @escaping () -> Void,
        trailingView: @escaping () -> Content = { EmptyView() }
    ) {
        self.label = label
        self.isDestructive = isDestructive
        self.action = action
        self.trailingView = trailingView
    }
    
    var body: some View {
        Button {
            action()
        } label: {
            HStack {
                Text(label)
                
                if Content.self != EmptyView.self {
                    Spacer()
                    trailingView()
                }
            }
            .foregroundStyle(.white1)
            .font(.livvic(weight: .medium))
            .padding(12)
            .frame(maxWidth: .infinity)
            .background(isDestructive ? .red2 : .blue1)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
}

#Preview {
    AvalonButton("Start") {}
    AvalonButton("Delete", isDestructive: true) {}
    AvalonButton("Join Game (5 in lobby)") {} trailingView: {
        StackedProfilePictures {
            Color.red1
            Color.green1
            Color.blue2
        }
    }
}

//
//  AvalonButton.swift
//  Avalon
//
//  Created by Ben Key on 7/28/26.
//

import SwiftUI

struct AvalonButton: View {
    private let label: String
    private let isDestructive: Bool
    private let action: () -> Void
    
    init(_ label: String, isDestructive: Bool = false, action: @escaping () -> Void) {
        self.label = label
        self.isDestructive = isDestructive
        self.action = action
    }
    
    var body: some View {
        Button {
            action()
        } label: {
            Text(label)
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
}

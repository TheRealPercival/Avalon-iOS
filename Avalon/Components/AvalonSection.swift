//
//  AvalonSection.swift
//  Avalon
//
//  Created by Ben Key on 9/6/26.
//

import SwiftUI

struct AvalonSection<Content: View>: View {
    private let title: String
    private let content: () -> Content
    
    init(_ title: String, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.content = content
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .foregroundStyle(.secondaryText)
                .font(.livvic(size: .note))
            
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

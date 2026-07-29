//
//  AvalonHeader.swift
//  Avalon
//
//  Created by Ben Key on 7/29/26.
//

import SwiftUI

struct AvalonHeader: View {
    var body: some View {
        HStack(spacing: 12) {
            Image(.merlinCutout)
                .resizable()
                .frame(maxWidth: 81, maxHeight: 60)
            
            VStack(alignment: .leading, spacing: -10) {
                Text("Avalon")
                    .foregroundStyle(.primaryText)
                    .font(.livvic(size: 50, weight: .medium))
                
                Text("The Real Percival")
                    .foregroundStyle(.secondaryText)
                    .font(.livvic(size: 16, weight: .regular, italic: true))
            }
            .padding(.top, -6)
        }
    }
}

#Preview {
    AvalonHeader()
}

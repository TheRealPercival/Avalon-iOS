//
//  AvalonHeader.swift
//  Avalon
//
//  Created by Ben Key on 7/29/26.
//

import SwiftUI

struct AvalonHeader: View {
    @ScaledMetric private var imageWidth = 80
    
    private var topOffset: CGFloat {
        -imageWidth * 7 / 40
    }
    
    var body: some View {
        HStack(spacing: 8) {
            Image(.merlinCutout)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: imageWidth, maxHeight: imageWidth)
                .padding(.top, topOffset)
            
            VStack(alignment: .leading, spacing: -10) {
                Text("Avalon")
                    .foregroundStyle(.primaryText)
                    .font(.livvic(size: 50, weight: .medium))
                
                Text("The Real Percival")
                    .foregroundStyle(.secondaryText)
                    .font(.livvic(size: 16, weight: .regular, italic: true))
            }
        }
    }
}

#Preview {
    AvalonHeader()
}

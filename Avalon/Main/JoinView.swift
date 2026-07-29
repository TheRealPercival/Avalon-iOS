//
//  JoinView.swift
//  Avalon
//
//  Created by Ben Key on 7/29/26.
//

import SwiftUI

struct JoinView: View {
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 0) {
                    Text("Join View")
                }
                .padding(16)
                .frame(maxWidth: .infinity, minHeight: geometry.size.height)
            }
            .scrollBounceBehavior(.basedOnSize)
            .background {
                Color.fullBackground
                    .ignoresSafeArea()
            }
        }
    }
}

#Preview {
    JoinView()
}

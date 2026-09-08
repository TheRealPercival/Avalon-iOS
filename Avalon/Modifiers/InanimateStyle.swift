//
//  InanimateStyle.swift
//  Avalon
//
//  Created by Ben Key on 9/7/26.
//

import SwiftUI

extension View {
    func inanimate() -> some View {
        self.modifier(InanimateStyle())
    }
}

struct InanimateStyle: ViewModifier {
    func body(content: Content) -> some View {
        content.transaction { $0.animation = .none }
    }
}

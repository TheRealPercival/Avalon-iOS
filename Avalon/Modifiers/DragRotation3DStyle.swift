//
//  DragRotation3DStyle.swift
//  Avalon
//
//  Created by Ben Key on 9/7/26.
//

import SwiftUI

extension View {
    func dragRotation3D() -> some View {
        self.modifier(DragRotation3DStyle())
    }
}

struct DragRotation3DStyle: ViewModifier {
    @State private var rotation: CGSize = .zero
    
    func body(content: Content) -> some View {
        content
            .rotation3DEffect(
                .degrees(degrees),
                axis: (x: -xAxis, y: yAxis, z: 0.0)
            )
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        rotation = gesture.translation
                    }
                    .onEnded { gesture in
                        withAnimation {
                            rotation = .zero
                        }
                    }
            )
    }
    
    private var totalDragDistance: Double {
        abs(rotation.width) + abs(rotation.height)
    }
    
    private var xAxis: Double {
        guard rotation != .zero else { return 0 }
        return rotation.height / totalDragDistance
    }
    
    private var yAxis: Double {
        guard rotation != .zero else { return 0 }
        return rotation.width / totalDragDistance
    }
    
    private var degrees: Double {
        pow(pow(rotation.width, 2) + pow(rotation.height, 2), 0.25)
    }
}

#Preview {
    Text("Drag me!")
        .font(.livvic(size: .heading))
        .padding(16)
        .background(Color.blue1)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .dragRotation3D()
}

//
//  StackedProfilePictures.swift
//  Avalon
//
//  Created by Ben Key on 7/29/26.
//

import SwiftUI

struct StackedProfilePictures<Content: View>: View {
    @ScaledMetric private var imageWidth = 32
    
    private let profilePicturesView: () -> Content
    
    private var cutoutWidth: Double {
        imageWidth * 1.1
    }
    
    init(@ViewBuilder profilePicturesView: @escaping () -> Content) {
        self.profilePicturesView = profilePicturesView
    }
    
    var body: some View {
        HStack(spacing: -imageWidth / 2) {
            Group(subviews: profilePicturesView()) { profilePictures in
                let array = Array(profilePictures.enumerated())
                ForEach(array, id: \.offset) { index, profilePicture in
                    profilePicture
                        .frame(width: imageWidth, height: imageWidth)
                        .clipShape(.circle)
                        .mask {
                            Circle()
                                .overlay {
                                    if index != 0 {
                                        Circle()
                                            .frame(width: cutoutWidth, height: cutoutWidth)
                                            .offset(x: -imageWidth / 2)
                                            .blendMode(.destinationOut)
                                    }
                                }
                        }
                }
                
                if array.isEmpty {
                    Color.clear.frame(width: imageWidth, height: imageWidth)
                }
            }
        }
    }
}

#Preview {
    StackedProfilePictures {
        Color.red1
        Color.green1
        Color.blue1
    }
}

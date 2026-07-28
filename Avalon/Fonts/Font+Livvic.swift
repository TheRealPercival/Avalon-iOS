//
//  Font+Livvic.swift
//  Avalon
//
//  Created by Ben Key on 7/28/26.
//

import SwiftUI

extension Font {
    enum LivvicSize {
        case heading
        case subheading
        case body
        case note
        
        fileprivate var pointSize: CGFloat {
            switch self {
            case .heading: 36
            case .subheading: 26
            case .body: 18
            case .note: 14
            }
        }
        
        fileprivate var defaultWeight: Weight {
            switch self {
            case .heading: .semibold
            case .subheading: .medium
            case .body, .note: .regular
            }
        }
    }
    
    static var livvic: Font {
        livvic()
    }
    
    static func livvic(size: LivvicSize = .body, weight: Font.Weight? = nil, italic: Bool = false) -> Font {
        livvic(
            size: size.pointSize,
            weight: weight ?? size.defaultWeight,
            italic: italic
        )
    }
    
    static func livvic(size: CGFloat, weight: Font.Weight, italic: Bool = false) -> Font {
        custom(
            livvicFontName(weight: weight, italic: italic),
            size: size
        )
    }
    
    private static func livvicFontName(weight: Font.Weight, italic: Bool) -> String {
        if italic {
            return switch weight {
            case .thin: "Livvic-ThinItalic"
            case .ultraLight: "Livvic-ExtraLightItalic"
            case .light: "Livvic-LightItalic"
            case .regular: "Livvic-Italic"
            case .medium: "Livvic-MediumItalic"
            case .semibold: "Livvic-SemiBoldItalic"
            case .bold: "Livvic-BoldItalic"
            case .heavy, .black: "Livvic-BlackItalic"
            default: "Livvic-Italic"
            }
        } else {
            return switch weight {
            case .thin: "Livvic-Thin"
            case .ultraLight: "Livvic-ExtraLight"
            case .light: "Livvic-Light"
            case .regular: "Livvic-Regular"
            case .medium: "Livvic-Medium"
            case .semibold: "Livvic-SemiBold"
            case .bold: "Livvic-Bold"
            case .heavy, .black: "Livvic-Black"
            default: "Livvic-Regular"
            }
        }
    }
}

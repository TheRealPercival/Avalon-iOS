//
//  AvalonMenu.swift
//  Avalon
//
//  Created by Ben Key on 9/6/26.
//

import SwiftUI

struct AvalonMenu<MenuOption: Hashable>: View {
    @Binding private var selection: MenuOption
    
    private let options: [MenuOption]
    private let label: (MenuOption) -> String
    
    init(selection: Binding<MenuOption>, options: [MenuOption], label: @escaping (MenuOption) -> String) {
        self._selection = selection
        self.options = options
        self.label = label
    }
    
    var body: some View {
        Menu {
            Picker("Preset", selection: $selection) {
                ForEach(options, id: \.self) { option in
                    Text(label(option))
                }
            }
        } label: {
            HStack {
                Text(label(selection))
                Spacer()
                Image(systemName: "chevron.up.chevron.down")
            }
            .foregroundStyle(.primaryText)
            .font(.livvic)
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .overlay {
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(.tertiaryText)
        }
    }
}

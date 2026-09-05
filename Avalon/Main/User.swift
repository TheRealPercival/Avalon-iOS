//
//  User.swift
//  Avalon
//
//  Created by Ben Key on 8/20/26.
//

import Foundation

struct User: Decodable, Identifiable {
    let id: String
    let name: String?
    private let avatarURLString: String?
    
    var avatarURL: URL? {
        guard let avatarURLString else { return nil }
        return .init(string: avatarURLString)
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case avatarURLString = "avatarURL"
    }
}

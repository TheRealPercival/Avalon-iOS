//
//  SessionInfo.swift
//  Avalon
//
//  Created by Ben Key on 8/30/26.
//

struct SessionInfo: Decodable {
    let inSession: Bool
    let users: [User]
}

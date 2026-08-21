//
//  AvalonStorage.swift
//  Avalon
//
//  Created by Ben Key on 8/15/26.
//

import Foundation

final class AvalonStorage {
    static let shared: AvalonStorage = .init()
    
    var serverURL: URL? {
        get {
            UserDefaults.standard.url(forKey: Key.serverURL.rawValue)
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: Key.serverURL.rawValue)
        }
    }
    
    var serverInfo: ServerInfo? {
        get {
            let data = UserDefaults.standard.data(forKey: Key.serverInfo.rawValue)
            guard let data else { return nil }
            return try? JSONDecoder().decode(ServerInfo.self, from: data)
        }
        
        set {
            guard let data = try? JSONEncoder().encode(newValue) else { return }
            UserDefaults.standard.set(data, forKey: Key.serverInfo.rawValue)
        }
    }
}

extension AvalonStorage {
    enum Key: String {
        case serverURL
        case serverInfo
    }
}

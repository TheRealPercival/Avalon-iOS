//
//  Decodable+Extensions.swift
//  Avalon
//
//  Created by Ben Key on 9/5/26.
//

import Foundation

extension [Any] {
    func decodeObject<T: Decodable>(ofType type: T.Type) -> T? {
        guard let arg = first,
              let data = try? JSONSerialization.data(withJSONObject: arg),
              let object = try? JSONDecoder().decode(type.self, from: data)
        else {
            return nil
        }
        
        return object
    }
}

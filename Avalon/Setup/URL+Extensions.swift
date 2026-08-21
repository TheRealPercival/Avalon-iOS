//
//  URL+Extensions.swift
//  Avalon
//
//  Created by Ben Key on 8/15/26.
//

import Foundation

extension URL {
    var hostString: String {
        host() ?? absoluteString
    }
}

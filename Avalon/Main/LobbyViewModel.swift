//
//  LobbyViewModel.swift
//  Avalon
//
//  Created by Ben Key on 9/5/26.
//

import SwiftUI
import SocketIO

@Observable
class LobbyViewModel {
    var selectedPreset: String
    var isRequestingToLeave: Bool = false
    
    init() {
        self.selectedPreset = Self.mockPresets.first ?? "Classic"
    }
    
    func requestToLeaveSession(for socket: SocketIOClient, onSuccess: @escaping () -> Void) {
        socket.emitWithAck(ClientEvent.leaveSession.rawValue).timingOut(after: 5) { [weak self] args in
            guard self != nil else { return }
            
            guard args.first as? String != SocketAckStatus.noAck.rawValue else {
                // Show error probably
                return
            }
            
            guard let response = args.decodeObject(ofType: ActionSuccess.self) else { return }
            
            if response.success {
                onSuccess()
            } else {
                // Show error probably
            }
        }
    }
}

extension LobbyViewModel {
    static let mockPresets: [String] = [
        "Classic",
        "Basic",
        "Fancy",
        "Random"
    ]
}

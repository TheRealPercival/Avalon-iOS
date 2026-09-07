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
    
    var isTrapperEnabled: Bool = false
    var isLadyEnabled: Bool = false
    var isFailResetEnabled: Bool = false
    
    var selectedPlayer: UIColor?
    var isPlayerListOpen: Bool = false
    
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
    
    static let mockGridColors: [UIColor] = [
        .red1,
        .yellow,
        .green1,
        .blue1,
        .magenta,
        .red3,
        .green3,
        .blue3,
        .black,
        .white
    ]
}

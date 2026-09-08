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
    
    var isEditRolesOpen: Bool = false
    
    var isTrapperEnabled: Bool = false
    var isLadyEnabled: Bool = false
    var isFailResetEnabled: Bool = false
    
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
    
    static var mockRoles: [MockRole] {
        mockGoodRoles + mockEvilRoles
    }
    
    static let mockGoodRoles: [MockRole] = [
        .init(name: "Merlin", cardImage: .merlinCard, iconImage: .merlinIcon),
        .init(name: "Good 1", cardImage: .goodGuyCard, iconImage: .goodGuyIcon),
        .init(name: "Good 2", cardImage: .goodGuyCard, iconImage: .goodGuyIcon),
        .init(name: "Good 3", cardImage: .goodGuyCard, iconImage: .goodGuyIcon),
        .init(name: "Good 4", cardImage: .goodGuyCard, iconImage: .goodGuyIcon),
        .init(name: "Good 5", cardImage: .goodGuyCard, iconImage: .goodGuyIcon)
    ]
    
    static let mockEvilRoles: [MockRole] = [
        .init(name: "Morgana", cardImage: .morganaCard, iconImage: .morganaIcon),
        .init(name: "Evil 1", cardImage: .evilGuyCard, iconImage: .evilGuyIcon),
        .init(name: "Evil 2", cardImage: .evilGuyCard, iconImage: .evilGuyIcon),
        .init(name: "Evil 3", cardImage: .evilGuyCard, iconImage: .evilGuyIcon)
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
    
    static let mockAssassinRoles: [String] = [
        "Morgana",
        "Mordred",
        "Assassin"
    ]
}

struct MockRole: Identifiable {
    var id: String { name }
    
    let name: String
    let cardImage: UIImage
    let iconImage: UIImage
}

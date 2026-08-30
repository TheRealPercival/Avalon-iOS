//
//  JoinViewModel.swift
//  Avalon
//
//  Created by Ben Key on 8/20/26.
//

import SwiftUI
import SocketIO

@Observable
class JoinViewModel {
    var inSessionUsers: [User] = .init()
    
    private var hasFetchedInitialSessionList: Bool = false
    private var joinListenerId: UUID?
    private var leaveListenerId: UUID?
    
    func listenToSessionEvents(from socket: SocketIOClient) {
        getSessionList(from: socket)
        listenToSessionJoins(from: socket)
        listenToSessionLeaves(from: socket)
    }
    
    func onServerStatusChange(for socket: SocketIOClient) {
        guard socket.status == .connected else { return }
        
        fetchInitialSessionList(from: socket)
    }
    
    private func getSessionList(from socket: SocketIOClient) {
        guard !hasFetchedInitialSessionList, socket.status == .connected else { return }
         
        fetchInitialSessionList(from: socket)
    }
    
    private func fetchInitialSessionList(from socket: SocketIOClient) {
        socket.emitWithAck(ClientEvent.getSessionInfo.rawValue).timingOut(after: 5.0) { [weak self] args in
            guard let self else { return }
            
            guard args.first as? String != SocketAckStatus.noAck.rawValue else {
                // Show error or fail silently
                return
            }
            
            if let users = args.decodeObject(ofType: [User].self) {
                self.inSessionUsers = users
                self.hasFetchedInitialSessionList = true
            }
        }
    }
    
    private func listenToSessionJoins(from socket: SocketIOClient) {
        guard joinListenerId == nil else { return }
        
        let joinListenerId = socket.on(ServerEvent.joinedSession.rawValue) { [weak self] args, _ in
            guard let self else {
                socket.off(id: joinListenerId)
                return
            }
            
            if let user = args.decodeObject(ofType: User.self) {
                self.inSessionUsers.append(user)
            }
        }
        
        self.joinListenerId = joinListenerId
    }
    
    private func listenToSessionLeaves(from socket: SocketIOClient) {
        guard leaveListenerId == nil else { return }
        
        let leaveListenerId = socket.on(ServerEvent.leftSession.rawValue) { [weak self] args, _ in
            guard let self else {
                socket.off(id: leaveListenerId)
                return
            }
            
            if let user = args.decodeObject(ofType: User.self) {
                self.inSessionUsers.removeAll { $0.id == user.id }
            }
        }
        
        self.leaveListenerId = leaveListenerId
    }
}

fileprivate extension [Any] {
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

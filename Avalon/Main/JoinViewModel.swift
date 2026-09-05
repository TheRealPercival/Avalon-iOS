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
    var isInSession: Bool = false
    var isOnGameScreen: Bool = false
    
    private var hasFetchedInitialSessionList: Bool = false
    private var joinListenerId: UUID?
    private var leaveListenerId: UUID?
    
    func listenToSessionEvents(from socket: SocketIOClient) {
        getSessionInfoIfNeeded(from: socket)
        listenToSessionJoins(from: socket)
        listenToSessionLeaves(from: socket)
    }
    
    func onServerStatusChange(for socket: SocketIOClient) {
        guard socket.status == .connected else { return }
        
        fetchSessionInfo(from: socket)
    }
    
    func requestToJoinSession(for socket: SocketIOClient) {
        socket.emitWithAck(ClientEvent.joinSession.rawValue).timingOut(after: 5) { [weak self] args in
            guard let self else { return }
            
            guard args.first as? String != SocketAckStatus.noAck.rawValue else {
                // Show error probably
                return
            }
            
            guard let response = args.decodeObject(ofType: ActionSuccess.self) else { return }
            
            if response.success {
                isInSession = true
            } else {
                // Show error probably
            }
        }
    }
    
    func handleGameNavigationChange(for socket: SocketIOClient) -> Void {
        if !isOnGameScreen && isInSession {
            socket.emit(ClientEvent.leaveSession.rawValue)
            isInSession = false
        }
    }
    
    func handleSessionStatusChange() -> Void {
        if isOnGameScreen != isInSession {
            isOnGameScreen = isInSession
        }
    }
    
    private func getSessionInfoIfNeeded(from socket: SocketIOClient) {
        guard !hasFetchedInitialSessionList, socket.status == .connected else { return }
         
        fetchSessionInfo(from: socket)
    }
    
    private func fetchSessionInfo(from socket: SocketIOClient) {
        socket.emitWithAck(ClientEvent.getSessionInfo.rawValue).timingOut(after: 5) { [weak self] args in
            guard let self else { return }
            
            guard args.first as? String != SocketAckStatus.noAck.rawValue else {
                // Show error or fail silently
                return
            }
            
            if let sessionInfo = args.decodeObject(ofType: SessionInfo.self) {
                self.isInSession = sessionInfo.inSession
                self.inSessionUsers = sessionInfo.users
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

import Foundation
import SwiftUI
import SceneKit

struct AlertWrapper: Identifiable {
    let id = UUID()
    let alert: Alert
}

final class WebSocketController: ObservableObject {
    @Published var alertWrapper: AlertWrapper?

    private var id: UUID!
    private let session: URLSession
    var socket: URLSessionWebSocketTask!
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    var enemy: SCNNode?

    init() {
        self.session = URLSession(configuration: .default)
        self.connect()
    }

    func connect() {
    self.socket = session.webSocketTask(with: URL(string: "wss://cops-and-robbers-server.herokuapp.com")!)
    self.listen()
    self.socket.resume()
    }
    
    func attachEnemy(_ enemy: SCNNode) {
        self.enemy = enemy
    }
    
    func sendDirection(_ direction: CGFloat) {
        guard let id = self.id else { return }
        // 1
            let directionMessage = DirectionUpdate(id: id, direction: direction)
        do {
          // 2
          let data = try encoder.encode(directionMessage)
          // 3
          self.socket.send(.data(data)) { (err) in
            if err != nil {
              print(err.debugDescription)
            }
          }
        } catch {
          print(error)
        }
    }
  
    func sendPosition(_ position: SCNVector3) {
        guard let id = self.id else { return }
        // 1
            let positionMessage = PositionUpdate(id: id, x: position.x, y: position.y, z: position.z)
        do {
          // 2
          let data = try encoder.encode(positionMessage)
          // 3
          self.socket.send(.data(data)) { (err) in
            if err != nil {
              print(err.debugDescription)
            }
          }
        } catch {
          print(error)
        }
    }
  
    func handle(_ data: Data) {
        do {
          // 1
          let sinData = try decoder.decode(QnAMessageSinData.self, from: data)
          // 2
          switch sinData.type {
          case .handshake:
            // 3
            print("Shook the hand")
            let message = try decoder.decode(QnAHandshake.self, from: data)
            self.id = message.id
          // 4
          case .enemyPosition:
            print("will handle enemy position")
            try self.handleEnemyPosition(data)
          case .enemyDirection:
            print("will handle enemy position")
            try self.handleEnemyDirection(data)
          default:
            break
          }
        } catch {
          print(error)
        }
    }
  
    func listen() {
        // 1
        self.socket.receive { [weak self] (result) in
          guard let self = self else { return }
          // 2
          switch result {
          case .failure(let error):
            print(error)
            return
          case .success(let message):
            // 4
            switch message {
            case .data(let data):
              self.handle(data)
            case .string(let str):
              guard let data = str.data(using: .utf8) else { return }
              self.handle(data)
            @unknown default:
              break
            }
          }
          // 5
          self.listen()
        }
    }
  
    func handleEnemyPosition(_ data: Data) throws {
        print("handle enemy position")
        let response = try decoder.decode(PositionUpdate.self, from: data)
        DispatchQueue.main.async {
            self.enemy?.position = SCNVector3(x: response.x, y: response.y, z: response.z)
        }
    }
    
    func handleEnemyDirection(_ data: Data) throws {
        print("handle enemy position")
        let response = try decoder.decode(DirectionUpdate.self, from: data)
        DispatchQueue.main.async {
            self.enemy?.runAction(
                SCNAction.rotateTo(x: 0.0, y: CGFloat(response.direction), z: 0.0, duration: 0.5, usesShortestUnitArc:true))
        }
    }
}

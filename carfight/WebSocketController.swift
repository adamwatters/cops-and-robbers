import Foundation
import SwiftUI
import SceneKit

let WEB_SOCKET_URL = "ws://192.168.4.60:3000"
//let WEB_SOCKET_URL = "wss://cops-and-robbers-server.herokuapp.com"

struct AlertWrapper: Identifiable {
    let id = UUID()
    let alert: Alert
}

protocol WebSocketDelegate: NSObjectProtocol {
    func handlePlayersUpdate(_ players: [Player])
}

final class WebSocketController: ObservableObject {
    @Published var alertWrapper: AlertWrapper?
    weak var delegate: WebSocketDelegate?
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
        self.socket = session.webSocketTask(with: URL(string: WEB_SOCKET_URL)!)
        self.listen()
        self.socket.resume()
    }
    
    func joinGame(playerName: String) {
        guard let id = self.id else { return }
        let joinMessage = JoinGame(playerName: playerName, id: id)
        do {
          let data = try encoder.encode(joinMessage)
          self.socket.send(.data(data)) { (err) in
            if err != nil {
              print(err.debugDescription)
            }
          }
        } catch {
          print(error)
        }
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
            let sinData = try decoder.decode(QnAMessageSinData.self, from: data)
            switch sinData.type {
                case .handshake:
                    print("Shook the hand")
                    let message = try decoder.decode(QnAHandshake.self, from: data)
                    self.id = message.id
                case .playersUpdate:
                    print("Recieved Players Update")
                    try self.handlePlayersUpdate(data)
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
    
    func handlePlayersUpdate(_ data: Data) throws {
        let response = try decoder.decode(PlayersUpdate.self, from: data)
        self.delegate?.handlePlayersUpdate(response.players)
    }
  
    func handleEnemyPosition(_ data: Data) throws {
        let response = try decoder.decode(PositionUpdate.self, from: data)
        DispatchQueue.main.async {
            self.enemy?.position = SCNVector3(x: response.x, y: response.y, z: response.z)
        }
    }
    
    func handleEnemyDirection(_ data: Data) throws {
        let response = try decoder.decode(DirectionUpdate.self, from: data)
        DispatchQueue.main.async {
            self.enemy?.runAction(
                SCNAction.rotateTo(x: 0.0, y: CGFloat(response.direction), z: 0.0, duration: 0.5, usesShortestUnitArc:true))
        }
    }
}

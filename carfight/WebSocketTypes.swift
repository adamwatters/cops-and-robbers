import Foundation
import SceneKit

enum QnAMessageType: String, Codable {
    // Client to server types
    case positionUpdate, directionUpdate, joinGame
    // Server to client types
    case handshake, playersUpdate, gameIsFull, enemyPosition, enemyDirection
}

struct Player: Codable {
    let id: UUID
    let handle: String
    let position: Int
}

struct QnAMessageSinData: Codable {
    let type: QnAMessageType
}

struct QnAHandshake: Codable {
    var type: QnAMessageType = .handshake
    let id: UUID
}

struct JoinGame: Codable {
    var type: QnAMessageType = .joinGame
    let handle: String
}

struct PlayersUpdate: Codable {
    var type: QnAMessageType
    let handle: String
    var players: [Player]
}

struct DirectionUpdate: Codable {
    var type: QnAMessageType = .directionUpdate
    let id: UUID
    let direction: CGFloat
}

struct PositionUpdate: Codable {
    var type: QnAMessageType = .positionUpdate
    let id: UUID
    let x: Float
    let y: Float
    let z: Float
}


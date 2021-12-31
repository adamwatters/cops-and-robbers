import Foundation
import SceneKit

enum QnAMessageType: String, Codable {
  // Client to server types
  case positionUpdate, directionUpdate
  // Server to client types
  case handshake, enemyPosition, enemyDirection
}

struct QnAMessageSinData: Codable {
  let type: QnAMessageType
}

struct QnAHandshake: Codable {
  let id: UUID
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


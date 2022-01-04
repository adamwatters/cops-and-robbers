//
//  Game.swift
//  carfight
//
//  Created by Adam Watters on 1/3/22.
//

import SwiftUI
import SpriteKit
import SceneKit

struct Game: View {
    let scene: SCNScene = SCNScene(named: "art.scnassets/arenas/Stadium.scn")!
    let overlay: SKScene = SKScene()
    let gameCoordinator: GameCoordinator
    init() {
        gameCoordinator = GameCoordinator(scene: scene, overlay: overlay)
    }
    var body: some View {
        ZStack {
            SceneView(scene: scene, delegate: gameCoordinator)
            SpriteView(scene: overlay, options: [.allowsTransparency])
        }.ignoresSafeArea()
    }
}

class GameCoordinator: NSObject  {
    let CollidingWithBall = 2
    var direction = float2()
    var scene:SCNScene!
    var overlay:SKScene!
    var ballNode:SCNNode!
    var carNode:SCNNode!
    var enemyNode:SCNNode!
    var selfieStickNode:SCNNode!
    var socket = WebSocketController()
    var motionForce = SCNVector3(0, 0, 0)
    init(scene: SCNScene, overlay: SKScene){
        super.init()
        self.scene = scene
        self.overlay = overlay
        self.setupScene()
        self.setupOverlay()
    }
    func setupScene() {
        ballNode = scene.rootNode.childNode(withName: "ball", recursively: true)!
        enemyNode = scene.rootNode.childNode(withName: "car2", recursively: true)!
        socket.attachEnemy(enemyNode)
        ballNode.physicsBody?.contactTestBitMask = CollidingWithBall
        selfieStickNode = scene.rootNode.childNode(withName: "selfieStick", recursively: true)!
        carNode = scene.rootNode.childNode(withName: "car1", recursively: true)!
        carNode.physicsBody = nil
    }
    func setupOverlay() {
        overlay.backgroundColor = .clear
        let pad = PadOverlay()
        pad.delegate = self
        pad.position = CGPoint(x: 20, y: 20)
        overlay.anchorPoint = CGPoint(x: 0, y: 1)
        overlay.size = CGSize(width: 400, height: 400)
        overlay.scaleMode = .aspectFill
//        let image = UIImage(named: "threezy")
//        let texture = SKTexture(image: image!)
//        let watermark = SKSpriteNode(texture: texture)
//        let watermarkWidth = 100
//        let watermarkHeight = watermarkWidth / 2
//        watermark.size = CGSize(width: watermarkWidth, height: watermarkHeight)
//        watermark.position = CGPoint(x: (watermarkWidth / 2) + (watermarkWidth / 8), y: (watermarkHeight / -2) - (watermarkWidth / 8))
//        overlay.addChild(watermark)
//        overlay.addChild(pad)
    }
}

extension GameCoordinator : SCNSceneRendererDelegate {
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        let ball = ballNode.presentation
        socket.sendPosition(ball.position)
        carNode.position = ball.position
        
        let ballPosition = SCNVector3(x: ball.position.x, y: ball.position.y + 5, z: ball.position.z)
//        print(carNode.orientation)
        carNode.simdRotation.y = carNode.presentation.simdRotation.y + 1
        
        let targetPosition = SCNVector3(x: ballPosition.x, y: ballPosition.y + 5, z:ballPosition.z + 5)
        var cameraPosition = selfieStickNode.position
        selfieStickNode.camera?.zFar = 300
        
        let camDamping:Float = 0.3
        
        let xComponent = cameraPosition.x * (1 - camDamping) + targetPosition.x * camDamping
        let yComponent = cameraPosition.y * (1 - camDamping) + targetPosition.y * camDamping
        let zComponent = cameraPosition.z * (1 - camDamping) + targetPosition.z * camDamping
        
        cameraPosition = SCNVector3(x: xComponent, y: yComponent, z: zComponent)
        selfieStickNode.position = cameraPosition
        ballNode.physicsBody?.velocity += motionForce
    }
}

extension GameCoordinator : PadOverlayDelegate {
    func padOverlayVirtualStickInteractionDidStart(_ padNode: PadOverlay) {
        // nothing for now
    }

    func padOverlayVirtualStickInteractionDidChange(_ padNode: PadOverlay) {
        self.direction = float2(Float(padNode.stickPosition.x), -Float(padNode.stickPosition.y))
        self.motionForce = SCNVector3(x: Float(padNode.stickPosition.x) * 0.05, y:0, z: Float(padNode.stickPosition.y) * -0.05)
    }

    func padOverlayVirtualStickInteractionDidEnd(_ padNode: PadOverlay) {
        // nothing for now
    }
}

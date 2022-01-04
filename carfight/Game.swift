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
    
    var carDirection: vector_float2 {
        get {
            return direction
        }
        set {
            var newDirection = newValue
            let l = simd_length(newDirection)
            if l > 1.0 {
                newDirection *= 1 / l
            }
            direction = newDirection
            directionAngle = CGFloat(atan2f(direction.x, direction.y))
        }
    }

    var directionAngle: CGFloat = 0.0 {
        didSet {
            socket.sendDirection(directionAngle)
            carNode.runAction(
                SCNAction.rotateTo(x: 0.0, y: directionAngle, z: 0.0, duration: 0.5, usesShortestUnitArc:true))
        }
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
        let screenSize: CGRect = UIScreen.main.bounds
        
        overlay.backgroundColor = .clear
        overlay.anchorPoint = CGPoint(x: 0, y: 0)
        overlay.size = CGSize(width: screenSize.width, height: screenSize.height)
        overlay.scaleMode = .aspectFill
            
        let pad = PadOverlay()
        pad.delegate = self
        pad.position = CGPoint(x: screenSize.width - pad.size.width - 20, y: 30)
        overlay.addChild(pad)
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
        self.carDirection = float2(Float(padNode.stickPosition.x), -Float(padNode.stickPosition.y))
        self.motionForce = SCNVector3(x: Float(padNode.stickPosition.x) * 0.05, y:0, z: Float(padNode.stickPosition.y) * -0.05)
    }

    func padOverlayVirtualStickInteractionDidEnd(_ padNode: PadOverlay) {
        // nothing for now
    }
}

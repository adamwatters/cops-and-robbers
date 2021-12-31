//
//  GameViewController.swift
//  HitTheTree
//
//  Created by Brian Advent on 26.04.18.
//  Copyright © 2018 Brian Advent. All rights reserved.
//

import UIKit
import SceneKit

class GameViewController: UIViewController {
    
    let CollidingWithBall = 2
    var direction = float2()
    var sceneView:SCNView!
    var scene:SCNScene!
    
    var ballNode:SCNNode!
    var carNode:SCNNode!
    var enemyNode:SCNNode!
    var selfieStickNode:SCNNode!
    var socket = WebSocketController()
    
    var motionForce = SCNVector3(0, 0, 0)
    var overlay: Overlay? = nil
    
    override func viewDidLoad() {
        setupScene()
        setupNodes()
    }
    
    func setupScene(){
        sceneView = self.view as? SCNView
        sceneView.delegate = self
        overlay = Overlay(size: sceneView.bounds.size, controller: self)
        sceneView.overlaySKScene = overlay
        
        //sceneView.allowsCameraControl = true
        scene = SCNScene(named: "art.scnassets/PAScene.scn")
        sceneView.scene = scene
        
        scene.physicsWorld.contactDelegate = self
        
    }
    
    func setupNodes() {
        ballNode = scene.rootNode.childNode(withName: "ball", recursively: true)!
        enemyNode = scene.rootNode.childNode(withName: "car1", recursively: true)!
        socket.attachEnemy(enemyNode)
        ballNode.physicsBody?.contactTestBitMask = CollidingWithBall
        selfieStickNode = scene.rootNode.childNode(withName: "selfieStick", recursively: true)!
        carNode = scene.rootNode.childNode(withName: "car2", recursively: true)!
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
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

}

extension GameViewController : SCNSceneRendererDelegate {
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

extension GameViewController : PadOverlayDelegate {
    func padOverlayVirtualStickInteractionDidStart(_ padNode: PadOverlay) {
        if padNode == overlay!.controlOverlay!.rightPad {
         
        }
    }

    func padOverlayVirtualStickInteractionDidChange(_ padNode: PadOverlay) {
        if padNode == overlay!.controlOverlay!.rightPad {
            self.carDirection = float2(Float(padNode.stickPosition.x), -Float(padNode.stickPosition.y))
            self.motionForce = SCNVector3(x: Float(padNode.stickPosition.x) * 0.05, y:0, z: Float(padNode.stickPosition.y) * -0.05)
        }
    }

    func padOverlayVirtualStickInteractionDidEnd(_ padNode: PadOverlay) {
        if padNode == overlay!.controlOverlay!.rightPad {
        }
    }
}

extension GameViewController : SCNPhysicsContactDelegate {
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        var contactNode:SCNNode!
        
        if contact.nodeA.name == "ball" {
            contactNode = contact.nodeB
        }else{
            contactNode = contact.nodeA
        }
        
//        if contactNode.physicsBody?.categoryBitMask == CollidingWithBall {
//            if contactNode.name == "tree" {
//                contactNode.isHidden = true
//
//                let sawSound = sounds["saw"]!
//                ballNode.runAction(SCNAction.playAudio(sawSound, waitForCompletion: false))
//
//                let waitAction = SCNAction.wait(duration: 15)
//                let unhideAction = SCNAction.run { (node) in
//                    node.isHidden = false
//                }
//
//                let actionSequence = SCNAction.sequence([waitAction, unhideAction])
//
//                contactNode.runAction(actionSequence)
//            }
//        }
        
    }
    
    
}


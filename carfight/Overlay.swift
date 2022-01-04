/*
 Copyright (C) 2018 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 This class manages the 2D overlay (score).
*/
//
//import Foundation
//import SceneKit
//import SpriteKit
//
//class Overlay: SKScene {
//    private var overlayNode: SKNode
//    private var congratulationsGroupNode: SKNode?
//    private var collectedKeySprite: SKSpriteNode!
//    private var collectedGemsSprites = [SKSpriteNode]()
//    
//    
//#if os( iOS )
//    public var controlOverlay: ControlOverlay?
//#endif
//
//// MARK: - Initialization
//    init(size: CGSize, controller: SceneCoordinator) {
//        overlayNode = SKNode()
//        super.init(size: size)
//        
//        let w: CGFloat = size.width
//        let h: CGFloat = size.height
//        
//        collectedGemsSprites = []
//        
//        // Setup the game overlays using SpriteKit.
//        scaleMode = .resizeFill
//        
//        addChild(overlayNode)
//        overlayNode.position = CGPoint(x: 0.0, y: h)
//        
//        
//        // The virtual D-pad
//        controlOverlay = ControlOverlay(frame: CGRect(x: CGFloat(0), y: CGFloat(0), width: w, height: h))
//            controlOverlay!.rightPad.delegate = controller
//        addChild(controlOverlay!)
//        
//        // Assign the SpriteKit overlay to the SceneKit view.
//        isUserInteractionEnabled = false
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    func layout2DOverlay() {
//        overlayNode.position = CGPoint(x: 0.0, y: size.height)
//
//        guard let congratulationsGroupNode = self.congratulationsGroupNode else { return }
//        
//        congratulationsGroupNode.position = CGPoint(x: CGFloat(size.width * 0.5), y: CGFloat(size.height * 0.5))
//        congratulationsGroupNode.xScale = 1.0
//        congratulationsGroupNode.yScale = 1.0
//        let currentBbox: CGRect = congratulationsGroupNode.calculateAccumulatedFrame()
//        
//        let margin: CGFloat = 25.0
//        let bounds = CGRect(x: 0, y: 0, width: size.width, height: size.height)
//        let maximumAllowedBbox: CGRect = bounds.insetBy(dx: margin, dy: margin)
//        
//        let top: CGFloat = currentBbox.maxY - congratulationsGroupNode.position.y
//        let bottom: CGFloat = congratulationsGroupNode.position.y - currentBbox.minY
//        let maxTopAllowed: CGFloat = maximumAllowedBbox.maxY - congratulationsGroupNode.position.y
//        let maxBottomAllowed: CGFloat = congratulationsGroupNode.position.y - maximumAllowedBbox.minY
//        
//        let `left`: CGFloat = congratulationsGroupNode.position.x - currentBbox.minX
//        let `right`: CGFloat = currentBbox.maxX - congratulationsGroupNode.position.x
//        let maxLeftAllowed: CGFloat = congratulationsGroupNode.position.x - maximumAllowedBbox.minX
//        let maxRightAllowed: CGFloat = maximumAllowedBbox.maxX - congratulationsGroupNode.position.x
//        
//        let topScale: CGFloat = top > maxTopAllowed ? maxTopAllowed / top: 1
//        let bottomScale: CGFloat = bottom > maxBottomAllowed ? maxBottomAllowed / bottom: 1
//        let leftScale: CGFloat = `left` > maxLeftAllowed ? maxLeftAllowed / `left`: 1
//        let rightScale: CGFloat = `right` > maxRightAllowed ? maxRightAllowed / `right`: 1
//        
//        let scale: CGFloat = min(topScale, min(bottomScale, min(leftScale, rightScale)))
//        
//        congratulationsGroupNode.xScale = scale
//        congratulationsGroupNode.yScale = scale
//    }
//    
//    func showVirtualPad() {
//        controlOverlay!.isHidden = false
//    }
//    
//    func hideVirtualPad() {
//        controlOverlay!.isHidden = true
//    }
//
//}
//
//

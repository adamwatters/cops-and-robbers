//
//  GameView.swift
//  carfight
//
//  Created by Adam Watters on 1/4/22.
//

import SwiftUI
import SceneKit
import SpriteKit

struct GameView: View {
    let scene: SCNScene = SCNScene(named: "art.scnassets/arenas/Stadium.scn")!
    let overlay: SKScene = SKScene()
    @ObservedObject var gameCoordinator: GameCoordinator
    init() {
        gameCoordinator = GameCoordinator(scene: scene, overlay: overlay)
        gameCoordinator.socket.delegate = gameCoordinator
    }
    var body: some View {
        ZStack {
            SceneView(scene: scene, delegate: gameCoordinator)
            SpriteView(scene: overlay, options: [.allowsTransparency])
            ZStack {
                if gameCoordinator.players.count > 0 {
                    VStack {
                        Text(gameCoordinator.players[0].playerName)
                    }.background(Color.black)
                } else {
                    NameInput(delegate: gameCoordinator)
                }
            }
        }.ignoresSafeArea()
    }
}

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
            SceneView(scene: scene, delegate: gameCoordinator).ignoresSafeArea()
            SpriteView(scene: overlay, options: [.allowsTransparency]).ignoresSafeArea()
            ZStack {
                if gameCoordinator.players.count > 0 {
                    VStack {
                        // todo: make this a list of players in the game, with position
                        // make it so more than 2 can play
                        HStack {
                            Spacer()
                            VStack {
                                ForEach(gameCoordinator.players, id: \.self.id) { player in
                                    Text(player.playerName)
                                }
                            }
                        }
                        Spacer()
                    }.padding()
                } else {
                    NameInput(delegate: gameCoordinator)
                }
            }
        }
    }
}

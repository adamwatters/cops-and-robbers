//
//  threelogoApp.swift
//  threelogo
//
//  Created by Adam Watters on 1/30/21.
//
import SwiftUI

@main
struct threelogoApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        WindowGroup {
            Game()

        }
    }
}

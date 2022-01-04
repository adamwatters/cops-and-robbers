//
//  AppDelegate.swift
//  Threezy
//
//  Created by Adam Watters on 8/18/21.
//

import Foundation
import SwiftUI

class AppDelegate: NSObject {
    
}

extension AppDelegate:  UIApplicationDelegate {
    static var orientationLock = UIInterfaceOrientationMask.portrait

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return AppDelegate.orientationLock
    }
}

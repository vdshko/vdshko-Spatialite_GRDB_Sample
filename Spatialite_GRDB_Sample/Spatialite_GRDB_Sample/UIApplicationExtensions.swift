//
//  UIApplicationExtensions.swift
//  Spatialite_GRDB_Sample
//
//  Created by Vladyslav Shkodych on 24.01.2025.
//

import UIKit

extension UIApplication {

    /// Returns the first window from the foreground active connected scene aka UIWindowScene.
    var activeWindow: UIWindow? {
        return connectedScenes
            .first { $0.activationState == UIScene.ActivationState.foregroundActive }
            .flatMap { $0 as? UIWindowScene }
            .flatMap { $0.windows.first }
    }

    /// Returns the root view controller from an active window.
    var rootViewController: UIViewController? { return activeWindow?.rootViewController }
}

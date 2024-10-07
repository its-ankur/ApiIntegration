//
//  SceneDelegate.swift
//  ApiIntegration
//
//  Created by Ankur on 03/10/24.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Ensure that the UIWindow is properly initialized
        guard let windowScene = (scene as? UIWindowScene) else { return }

        window = UIWindow(windowScene: windowScene)

        // Call checkLoginStatus to decide which screen to show
        checkLoginStatus()
    }

    func checkLoginStatus() {
        // Check if an accessToken exists in UserDefaults
        if let _ = UserDefaults.standard.string(forKey: "accessToken") {
            // User is logged in, navigate to Details Page
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let detailsVC = storyboard.instantiateViewController(withIdentifier: "TabBarViewController") as! TabBarViewController
            window?.rootViewController = UINavigationController(rootViewController: detailsVC)
            window?.makeKeyAndVisible()
        } else {
            // Show Login Page
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let loginVC = storyboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
            window?.rootViewController = UINavigationController(rootViewController: loginVC)
            window?.makeKeyAndVisible()
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
    }
}


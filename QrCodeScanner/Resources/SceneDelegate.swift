//
//  SceneDelegate.swift
//  QrCodeScanner
//
//  Created by Илья on 12.03.2023.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        let navigationController = UINavigationController()
        let builder = ModuleBuilder()
        let router = Router(navigationController: navigationController, assemblyBuilder: builder)
        router.initialViewController()
        window?.rootViewController = navigationController
        window?.overrideUserInterfaceStyle = .light
        window?.makeKeyAndVisible()
    }
}

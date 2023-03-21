//
//  ModuleBuilder.swift
//  QrCodeScanner
//
//  Created by Илья on 12.03.2023.
//

import UIKit
import Lottie


protocol BuilderProtocol {
    func createMainModule(router: RouterProtocol) -> UIViewController
    func createScanScreen(router: RouterProtocol) -> UIViewController
    func createTabBar(router: RouterProtocol) -> UITabBarController 
}

class ModuleBuilder: BuilderProtocol {
    func createMainModule(router: RouterProtocol) -> UIViewController {
        let view = ViewController()
        let presenter = MainScreenPresenter(view: view, router: router)
        view.presenter = presenter
        return view
    }

    func createScanScreen(router: RouterProtocol) -> UIViewController {
        let view = QrScannerViewController()
        let presenter = QrScannerPresenter(router: router, view: view)
        view.presenter = presenter
        let navigationController = UINavigationController(rootViewController: view)
        navigationController.modalPresentationStyle = .pageSheet
        navigationController.modalTransitionStyle = .flipHorizontal
        return navigationController
    }
    
    func createGenerateModule(router: RouterProtocol) -> UIViewController {
        let view = GenerateScreenViewController()
        let presenter = GenerateScreenPresenter(view: view, router: router)
        view.presenter = presenter
        return view
    }
    
    func createTabBar(router: RouterProtocol) -> UITabBarController {
            let firstVC = createMainModule(router: router)
            firstVC.tabBarItem = UITabBarItem(
                title: "Scan",
                image: UIImage(systemName: "qrcode.viewfinder"),
                selectedImage: UIImage(named: "first_icon_selected")
            )

            let secondVC = createGenerateModule(router: router)
            secondVC.tabBarItem = UITabBarItem(
                title: "Generate",
                image: UIImage(systemName: "livephoto.play"),
                selectedImage: UIImage(named: "second_icon_selected")
            )

            let tabBar = UITabBarController()
            tabBar.viewControllers = [firstVC, secondVC]
            return tabBar
        }
}

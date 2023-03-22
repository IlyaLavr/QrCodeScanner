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
    
    func createHistoryScreen(router: RouterProtocol) -> UIViewController {
        let view = HistoryScreenViewController()
        let presenter = HistoryScreenPresenter(view: view, router: router)
        view.presenter = presenter
        return view
    }
    
    func createTabBar(router: RouterProtocol) -> UITabBarController {
        let scanViewController = createMainModule(router: router)
        scanViewController.tabBarItem = UITabBarItem(
            title: Strings.TabBar.firstTitle,
            image: UIImage(systemName: Strings.TabBar.firstImage),
            selectedImage: nil
        )
        
        let generateViewController = createGenerateModule(router: router)
        generateViewController.tabBarItem = UITabBarItem(
            title: Strings.TabBar.secondTitle,
            image: UIImage(systemName: Strings.TabBar.secondImage),
            selectedImage: nil
        )
        
        let historyViewController = createHistoryScreen(router: router)
        historyViewController.tabBarItem = UITabBarItem(
            title: Strings.TabBar.thirdTitle,
            image: UIImage(systemName: Strings.TabBar.thirdImage),
            selectedImage: nil
        )
        
        let tabBar = UITabBarController()
        tabBar.tabBar.tintColor = UIColor(red: 76/255, green: 166/255, blue: 203/255, alpha: 1)
        tabBar.viewControllers = [scanViewController, generateViewController, historyViewController]
        return tabBar
    }
}

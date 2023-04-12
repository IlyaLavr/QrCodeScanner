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
    func createGenerateModule(router: RouterProtocol) -> UIViewController
    func createHistoryScreen(router: RouterProtocol) -> UIViewController
    func createDetailModule(code: QrCode, router: RouterProtocol) -> UIViewController
    func createDetailModuleForGeneringCode(code: QrCode, router: RouterProtocol) -> UIViewController
    func createMapScreen(router: RouterProtocol) -> UIViewController
    func createMapDetailScreen(code: QrCode, router: RouterProtocol) -> UIViewController
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
        navigationController.modalTransitionStyle = .coverVertical
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
    
    func createMapDetailScreen(code: QrCode, router: RouterProtocol) -> UIViewController {
        let view = MapDetailScreen()
        let presenter = MapScreenDetailPresenter(code: code, view: view, router: router)
        view.presenter = presenter
        return view
    }
    
    func createTabBar(router: RouterProtocol) -> UITabBarController {
        let tabBar = CustomTabBarController(router: router)
        return tabBar
    }
    
    func createDetailModule(code: QrCode, router: RouterProtocol) -> UIViewController {
        let view = ScanningQrCodeDetailScreen()
        let presenter = ScanningCodeDetailPresenter(code: code, view: view, router: router)
        view.presenter = presenter
        return view
    }
    
    func createDetailModuleForGeneringCode(code: QrCode, router: RouterProtocol) -> UIViewController {
        let view = SavingGeneringCodeViewController()
        let presenter = GeneringCodeDetailPresenter(code: code, view: view, router: router)
        view.presenter = presenter
        return view
    }
    
    func createMapScreen(router: RouterProtocol) -> UIViewController {
        let view = MapScreenViewController()
        let presenter = MapScreenPresenter(view: view, router: router)
        view.presenter = presenter
        return view
    }
}

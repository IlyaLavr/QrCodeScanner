//
//  Router.swift
//  QrCodeScanner
//
//  Created by Илья on 12.03.2023.
//

import UIKit

protocol RouterMain {
    var navigationController: UINavigationController? { get set }
    var assemblyBuilder: BuilderProtocol? { get set }
}

protocol RouterProtocol: RouterMain {
    func initialViewController()
    func showQrScanner()
    func showDetailScanCode(code: QrCode, index: IndexPath)
    func showDetailGeneratedCode(code: QrCode, index: IndexPath)
    func showMapScreen()
    func showMapDetailScreen(code: QrCode)
    func popToRoot()
}

class Router: RouterProtocol {
    var navigationController: UINavigationController?
    var assemblyBuilder: BuilderProtocol?
    
    init(navigationController: UINavigationController, assemblyBuilder: BuilderProtocol) {
        self.navigationController = navigationController
        self.assemblyBuilder = assemblyBuilder
    }
    
    func initialViewController() {
        if let navigationController = navigationController {
            guard let mainViewController = assemblyBuilder?.createTabBar(router: self) else { return }
            navigationController.viewControllers = [mainViewController]
        }
    }
    
    func showQrScanner() {
        if let navigationController = navigationController {
            guard let qrScannerNavigationController = assemblyBuilder?.createScanScreen(router: self) else { return }
            navigationController.present(qrScannerNavigationController, animated: true)
        }
    }
    
    func showDetailScanCode(code: QrCode, index: IndexPath) {
        if let navigationController = navigationController {
            guard let detailViewController = assemblyBuilder?.createDetailModule(code: code, router: self, index: index) else { return }
            navigationController.pushViewController(detailViewController, animated: true)
        }
    }
    
    func showDetailGeneratedCode(code: QrCode, index: IndexPath) {
        if let navigationController = navigationController {
            guard let detailViewController = assemblyBuilder?.createDetailModuleForGeneringCode(code: code, router: self, index: index) else { return }
            navigationController.pushViewController(detailViewController, animated: true)
        }
    }
    
    func showMapScreen() {
        if let navigationController = navigationController {
            guard let mapNavigationController = assemblyBuilder?.createMapScreen(router: self) else { return }
            navigationController.pushViewController(mapNavigationController, animated: true)
        }
    }
    
    func showMapDetailScreen(code: QrCode) {
        if let navigationController = navigationController {
            guard let mapNavigationController = assemblyBuilder?.createMapDetailScreen(code: code, router: self) else { return }
            navigationController.pushViewController(mapNavigationController, animated: true)
        }
    }
    
    func popToRoot() {
        if let navigationController = navigationController {
            navigationController.popToRootViewController(animated: true)
        }
    }
}

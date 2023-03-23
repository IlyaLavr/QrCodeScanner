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
    func showDetailScanCode(code: QrCode)
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
    
    func showDetailScanCode(code: QrCode) {
        if let navigationController = navigationController {
            guard let detailViewController = assemblyBuilder?.createDetailModule(code: code, router: self) else { return }
            navigationController.pushViewController(detailViewController, animated: true)
        }
    }
}

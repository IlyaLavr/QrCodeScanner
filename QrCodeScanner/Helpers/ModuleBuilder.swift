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
        let model = Model()
        let presenter = QrScannerPresenter(router: router, model: model, view: view)
        view.presenter = presenter
        let navigationController = UINavigationController(rootViewController: view)
        navigationController.modalPresentationStyle = .pageSheet
        navigationController.modalTransitionStyle = .flipHorizontal
        return navigationController
    }
}

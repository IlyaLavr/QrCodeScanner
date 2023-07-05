//
//  CustomTabBar.swift
//  QrCodeScanner
//
//  Created by Илья on 13.04.2023.
//

import UIKit

class CustomTabBarController: UITabBarController {
    
    let router: RouterProtocol
    
    init(router: RouterProtocol) {
        self.router = router
        super.init(nibName: nil, bundle: nil)
        setupTabBar()
        setupTabBarAppearance()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupTabBar() {
        var viewControllers = [UIViewController]()
        
        if let scanViewController = router.assemblyBuilder?.createMainModule(router: router) {
            scanViewController.tabBarItem = UITabBarItem(
                title: Strings.TabBar.firstTitle,
                image: UIImage(systemName: Strings.TabBar.firstImage),
                selectedImage: nil
            )
            viewControllers.append(scanViewController)
        }
        
        if let generateViewController = router.assemblyBuilder?.createGenerateModule(router: router) {
            generateViewController.tabBarItem = UITabBarItem(
                title: Strings.TabBar.secondTitle,
                image: UIImage(systemName: Strings.TabBar.secondImage),
                selectedImage: nil
            )
            viewControllers.append(generateViewController)
        }
        
        if let historyViewController = router.assemblyBuilder?.createHistoryScreen(router: router) {
            historyViewController.tabBarItem = UITabBarItem(
                title: Strings.TabBar.thirdTitle,
                image: UIImage(systemName: Strings.TabBar.thirdImage),
                selectedImage: nil
            )
            viewControllers.append(historyViewController)
        }
        self.viewControllers = viewControllers
    }
    
    private func setupTabBarAppearance() {
        tabBar.isTranslucent = true
        tabBar.barTintColor = .clear
        tabBar.shadowImage = UIImage()
        tabBar.layer.masksToBounds = false
        
        let blurEffect = UIBlurEffect(style: .systemThickMaterial)
        let alpha: CGFloat = 0.97
            let blurView = UIVisualEffectView(effect: blurEffect)
            blurView.frame = tabBar.bounds
            blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            blurView.alpha = alpha
            tabBar.insertSubview(blurView, at: 0)
        
        tabBar.layer.shadowColor = UIColor.darkGray.cgColor
        tabBar.layer.shadowOpacity = 0.2
        tabBar.layer.shadowOffset = CGSize(width: 0, height: -1)
        tabBar.layer.shadowRadius = 3
    }
}

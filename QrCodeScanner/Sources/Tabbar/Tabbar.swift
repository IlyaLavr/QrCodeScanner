//
//  Tabbar.swift
//  QrCodeScanner
//
//  Created by Илья on 20.03.2023.
//

import UIKit

class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let firstVC = ViewController()
        firstVC.tabBarItem = UITabBarItem(title: "Первый", image: UIImage(named: "first_icon"), selectedImage: UIImage(named: "first_icon_selected"))
        
        let secondVC = ViewController()
        secondVC.tabBarItem = UITabBarItem(title: "Второй", image: UIImage(named: "second_icon"), selectedImage: UIImage(named: "second_icon_selected"))
        
        let tabBarList = [firstVC, secondVC]
        self.viewControllers = tabBarList
    }
}

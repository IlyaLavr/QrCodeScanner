//
//  ViewController.swift
//  QrCodeScanner
//
//  Created by Илья on 12.03.2023.
//

import UIKit
import SnapKit
import Lottie

protocol MainViewProtocol: AnyObject {
}

final class ViewController: UIViewController, MainViewProtocol {
    var presenter: MainPresenterProtocol?
    
    // MARK: - Elements
    
    private lazy var background: UIImageView = {
        let obj = UIImageView(image: UIImage(named: Strings.MainScreen.background))
         return obj
     }()
    
    private lazy var imageAnimation: LottieAnimationView = {
        let animation = LottieAnimationView()
        animation.animation = LottieAnimation.named(Strings.MainScreen.animation)
        animation.loopMode = .loop
        animation.animationSpeed = 0.8
        animation.play()
        return animation
    }()
    
    private lazy var button: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: Strings.MainScreen.button), for: .normal)
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.2
        button.layer.shadowOffset = .zero
        button.layer.shadowRadius = 10
        button.addTarget(self, action: #selector(startScan), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lyfecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupHierarhy()
        makeConstraints()
    }
    
    // MARK: - Setup
    
    private func setupHierarhy() {
        view.addSubview(background)
        view.addSubview(imageAnimation)
        view.addSubview(button)
    }
    
    private func makeConstraints() {
        background.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        imageAnimation.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.top.equalTo(view).offset(110)
            make.height.width.equalTo(350)
        }
        
        button.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.bottom.equalTo(view.snp.bottom).offset(-150)
            make.height.width.equalTo(100)
        }
    }
    
    // MARK: - Actions
    
    @objc private func startScan() {
        presenter?.goToScanVc()
    }
}

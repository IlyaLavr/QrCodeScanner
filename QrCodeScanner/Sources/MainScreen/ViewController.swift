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
    func startScan()
}

class ViewController: UIViewController, MainViewProtocol {
    
//    var presenter: MainPresenterProtocol?
    
    // MARK: - Elements
    
    lazy var imageAnimation: LottieAnimationView = {
        let animation = LottieAnimationView()
        animation.animation = LottieAnimation.named("62699-qr-code-scanner")
        animation.loopMode = .loop
        animation.animationSpeed = 1
        animation.play()
        return animation
    }()
    
    private lazy var button: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemGreen
        button.setTitle("Scan", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: CGFloat(16))
        button.layer.cornerRadius = 45
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.4
        button.layer.shadowOffset = .zero
        button.layer.shadowRadius = 20
        button.addTarget(self, action: #selector(startScan), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lyfecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupHierarhy()
        makeConstraints()
    }
    
    // MARK: - Setup
    
    func setupHierarhy() {
        view.addSubview(imageAnimation)
        view.addSubview(button)
    }
    
    func makeConstraints() {
        imageAnimation.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.top.equalTo(view).offset(90)
            make.height.width.equalTo(400)
        }
        
        button.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.top.equalTo(imageAnimation.snp.bottom).offset(30)
            make.height.width.equalTo(90)
        }
    }
    
    // MARK: - Actions
    
    @objc func startScan() {
    }
}

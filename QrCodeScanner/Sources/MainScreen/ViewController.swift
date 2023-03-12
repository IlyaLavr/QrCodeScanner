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
    
    var presenter: MainPresenterProtocol?
    
    // MARK: - Elements
    
    lazy var imageAnimation: LottieAnimationView = {
        let animation = LottieAnimationView()
        animation.animation = LottieAnimation.named("main")
        animation.loopMode = .loop
        animation.animationSpeed = 0.8
        animation.play()
        return animation
    }()
    
    private lazy var button: UIButton = {
        let button = UIButton()
        button.backgroundColor = .white
        button.setTitleColor(.black, for: .normal)
        button.setTitle("Scan", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: CGFloat(35))
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.cornerRadius = 25
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
    
    func setupHierarhy() {
        view.addSubview(imageAnimation)
        view.addSubview(button)
    }
    
    func makeConstraints() {
        imageAnimation.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.top.equalTo(view).offset(110)
            make.height.width.equalTo(350)
        }
        
        button.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.top.equalTo(imageAnimation.snp.bottom).offset(90)
            make.height.equalTo(70)
            make.width.equalTo(180)
        }
    }
    
    // MARK: - Actions
    
    @objc func startScan() {
        presenter?.goToScanVc()
    }
}

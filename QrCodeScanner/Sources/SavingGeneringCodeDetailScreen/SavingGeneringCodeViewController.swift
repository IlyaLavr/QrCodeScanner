//
//  SavingGeneringCodeViewController.swift
//  QrCodeScanner
//
//  Created by Илья on 23.03.2023.
//

import UIKit
protocol SavingGeneringCodeViewProtocol: AnyObject {
    func setupDetailedView(name: String, date: String?, image: Data?)
}

class SavingGeneringCodeViewController: UIViewController {
    var presenter: GeneringCodeDetailProtocol?
    
    private lazy var background: UIImageView = {
        let obj = UIImageView(image: UIImage(named: Strings.GenerateScreen.background))
        return obj
    }()
    
    // MARK: - Elements
    
    private lazy var nameCode: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.text = ""
        return label
    }()
    
    private lazy var dateGenering: UILabel = {
        let text = UILabel()
        text.textColor = .black
        text.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        text.text = ""
        return text
    }()
    
    private lazy var imageQrCode: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 20
        imageView.layer.shadowColor = UIColor.black.cgColor
        imageView.layer.shadowOpacity = 0.2
        imageView.layer.shadowOffset = .zero
        imageView.layer.shadowRadius = 20
        return imageView
    }()
    
    private lazy var buttonSave: UIButton = {
        let button = UIButton()
        let image = UIImage(systemName: Strings.GenerateScreen.buttonSave)?.resized(to: CGSize(width: 70, height: 70)).withTintColor(UIColor(red: 76/255, green: 166/255, blue: 203/255, alpha: 1))
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(saveToGalery), for: .touchUpInside)
        return button
    }()
    
    private lazy var buttonShare: UIButton = {
        let button = UIButton()
        let image = UIImage(systemName: Strings.GenerateScreen.buttonShare)?.resized(to: CGSize(width: 70, height: 70)).withTintColor(UIColor(red: 76/255, green: 166/255, blue: 203/255, alpha: 1))
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(shareQrCode), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupHierarhy()
        makeConstraints()
        presenter?.setUpParametersCode()
    }
    
    // MARK: - Setup
    
    private func setupHierarhy() {
        view.addSubview(background)
        view.addSubview(nameCode)
        view.addSubview(imageQrCode)
        view.addSubview(dateGenering)
        view.addSubview(buttonSave)
        view.addSubview(buttonShare)
    }
    
    private func makeConstraints() {
        background.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        nameCode.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.top.equalToSuperview().offset(100)
            make.height.equalTo(30)
        }
        
        dateGenering.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.top.equalTo(nameCode.snp.bottom).offset(5)
            make.height.equalTo(20)
        }
        
        imageQrCode.snp.makeConstraints { make in
            make.top.equalTo(nameCode.snp.bottom).offset(50)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(300)
        }
        
        buttonSave.snp.makeConstraints { make in
            make.left.equalTo(view.snp.left).offset(70)
            make.top.equalTo(imageQrCode.snp.bottom).offset(70)
            make.height.width.equalTo(100)
        }
        
        buttonShare.snp.makeConstraints { make in
            make.right.equalTo(view.snp.right).offset(-70)
            make.height.width.equalTo(100)
            make.top.equalTo(imageQrCode.snp.bottom).offset(70)
        }
    }
    
    // MARK: - Action
    
    @objc func saveToGalery() {
        
    }
    
    @objc func shareQrCode() {
        
    }
}

// MARK: - Extension

extension SavingGeneringCodeViewController: SavingGeneringCodeViewProtocol {
    func setupDetailedView(name: String, date: String?, image: Data?) {
        nameCode.text = name
        dateGenering.text = date
        imageQrCode.image = UIImage(data: image ?? Data())
    }
}

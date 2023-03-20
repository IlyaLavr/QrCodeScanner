//
//  GenerateScreenViewController.swift
//  QrCodeScanner
//
//  Created by Илья on 20.03.2023.
//

import CoreImage
import UIKit

protocol GenerateScreenViewProtocol: AnyObject {
}

class GenerateScreenViewController: UIViewController, GenerateScreenViewProtocol {
    var presenter: GenerateScreenPresenterProtocol?
    
    // MARK: - Elements
    
    lazy var textFieldLink: UITextField = {
        let textField = UITextField()
        textField.textColor = .black
        textField.backgroundColor = .white
        textField.textAlignment = .center
        textField.placeholder = "Адрес"
        textField.layer.cornerRadius = 17
        textField.layer.shadowColor = UIColor.black.cgColor
        textField.layer.shadowOpacity = 0.2
        textField.layer.shadowOffset = .zero
        textField.layer.shadowRadius = 17
        textField.delegate = self
        return textField
    }()
    
    lazy var imageQrCode: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 20
        imageView.layer.shadowColor = UIColor.black.cgColor
        imageView.layer.shadowOpacity = 0.2
        imageView.layer.shadowOffset = .zero
        imageView.layer.shadowRadius = 20
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private lazy var button: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "button"), for: .normal)
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.2
        button.layer.shadowOffset = .zero
        button.layer.shadowRadius = 10
        button.addTarget(self, action: #selector(generate), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupHierarhy()
        makeConstraints()
    }
    
    // MARK: - Setup
    
    private func setupHierarhy() {
        view.addSubview(textFieldLink)
        view.addSubview(button)
        view.addSubview(imageQrCode)
    }
    
    private func makeConstraints() {
        textFieldLink.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.top.equalToSuperview().offset(100)
            make.height.equalTo(40)
            make.left.equalTo(view.snp.left).offset(20)
            make.right.equalTo(view.snp.right).offset(-20)
        }
        
        imageQrCode.snp.makeConstraints { make in
            make.top.equalTo(textFieldLink.snp.bottom).offset(50)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(300)
        }
        
        button.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.bottom.equalTo(additionalSafeAreaInsets).offset(-100)
            make.height.width.equalTo(60)
        }
    }
    
    // MARK: - Actions
    
    @objc private func generate() {
        guard let text = textFieldLink.text, !text.isEmpty else { return }
        imageQrCode.image = generateQRCode(from: text, size: imageQrCode.bounds.size)
    }
    
    // MARK: - Functions
    
    private func generateQRCode(from string: String, size: CGSize) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)
        guard let qrFilter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
        qrFilter.setValue(data, forKey: "inputMessage")
        qrFilter.setValue("Q", forKey: "inputCorrectionLevel")
        
        guard let qrCodeImage = qrFilter.outputImage else { return nil }
        let scaleX = size.width / qrCodeImage.extent.size.width
        let scaleY = size.height / qrCodeImage.extent.size.height
        let scale = min(scaleX, scaleY)
        let scaledImage = qrCodeImage.transformed(by: CGAffineTransform(scaleX: scale, y: scale))
        let context = CIContext(options: nil)
        guard let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) else { return nil }
        return UIImage(cgImage: cgImage)
    }
}

// MARK: - Extensions

extension GenerateScreenViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

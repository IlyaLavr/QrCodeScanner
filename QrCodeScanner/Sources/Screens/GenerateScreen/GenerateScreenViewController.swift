//
//  GenerateScreenViewController.swift
//  QrCodeScanner
//
//  Created by Илья on 20.03.2023.
//

import UIKit
import SnapKit
import CoreLocation

protocol GenerateScreenViewProtocol: AnyObject {
    func shareImageQrCode()
    func showAlert(with type: Alert)
    func showAlertSaveToGalery(with type: Alert, okHandler: ((UIAlertAction) -> Void)?, cancelHandler: ((UIAlertAction) -> Void)?)
    func saveQr()
}

class GenerateScreenViewController: UIViewController {
    var presenter: GenerateScreenPresenterProtocol?
    let locationManager = CLLocationManager()

    
    // MARK: - Elements
    
    private lazy var background: UIImageView = {
        let obj = UIImageView(image: UIImage(named: Strings.GenerateScreen.background))
        return obj
    }()
    
    lazy var textFieldLink: UITextField = {
        let textField = UITextField()
        textField.textColor = .darkGray
        textField.backgroundColor = nil
        textField.textAlignment = .center
        textField.placeholder = Strings.GenerateScreen.textFieldLinkPlaceholder
        textField.font = UIFont.systemFont(ofSize: 20, weight: .light)
        textField.layer.borderColor = UIColor.white.cgColor
        textField.layer.borderWidth = 3
        textField.layer.cornerRadius = 17
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
        imageView.isHidden = true
        return imageView
    }()
    
    private lazy var buttonGenerate: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: Strings.GenerateScreen.buttonGenerate), for: .normal)
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.2
        button.layer.shadowOffset = .zero
        button.layer.shadowRadius = 10
        button.addTarget(self, action: #selector(generate), for: .touchUpInside)
        return button
    }()
    
    private lazy var buttonSave: UIButton = {
        let button = UIButton()
        let image = UIImage(systemName: Strings.GenerateScreen.buttonSave)?.resized(to: CGSize(width: 30, height: 30)).withTintColor(UIColor(red: 76/255, green: 166/255, blue: 203/255, alpha: 1))
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(saveToGalery), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    
    private lazy var buttonShare: UIButton = {
        let button = UIButton()
        let image = UIImage(systemName: Strings.GenerateScreen.buttonShare)?.resized(to: CGSize(width: 30, height: 30)).withTintColor(UIColor(red: 76/255, green: 166/255, blue: 203/255, alpha: 1))
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(shareQrCode), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupHierarhy()
        makeConstraints()
        hideKeyboardWhenTappedAround()
    }
    
    // MARK: - Setup
    
    private func setupHierarhy() {
        view.addSubview(background)
        view.addSubview(textFieldLink)
        view.addSubview(buttonGenerate)
        view.addSubview(imageQrCode)
        view.addSubview(buttonSave)
        view.addSubview(buttonShare)
    }
    
    private func makeConstraints() {
        background.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        textFieldLink.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.top.equalToSuperview().offset(100)
            make.height.equalTo(60)
            make.left.equalTo(view.snp.left).offset(10)
            make.right.equalTo(view.snp.right).offset(-10)
        }
        
        imageQrCode.snp.makeConstraints { make in
            make.top.equalTo(textFieldLink.snp.bottom).offset(50)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(300)
        }
        
        buttonGenerate.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.bottom.equalTo(view.snp.bottom).offset(-150)
            make.height.width.equalTo(100)
        }
        
        buttonSave.snp.makeConstraints { make in
            make.right.equalTo(buttonGenerate.snp.left).offset(-35)
            make.height.width.equalTo(60)
            make.bottom.equalTo(view.snp.bottom).offset(-165)
        }
        
        buttonShare.snp.makeConstraints { make in
            make.left.equalTo(buttonGenerate.snp.right).offset(35)
            make.height.width.equalTo(60)
            make.bottom.equalTo(view.snp.bottom).offset(-165)
        }
    }
    
    // MARK: - Actions
    
    @objc private func generate() {
        guard let text = textFieldLink.text, !text.isEmpty else {
            DispatchQueue.main.async {
                self.imageQrCode.isHidden = true
            }
            presenter?.showAlertEmptyString()
            buttonShare.isHidden = true
            buttonSave.isHidden = true
            return
        }
        imageQrCode.image = generateQRCode(from: text, size: imageQrCode.bounds.size)
        imageQrCode.isHidden = false
        
        let date = Date()
        let dateString = DateFormatter.localizedDateString(from: date)
        guard let image = imageQrCode.image, let imageData = image.jpegData(compressionQuality: 1.0) else { return }
            locationManager.requestWhenInUseAuthorization()
            guard let currentLocation = locationManager.location else { return }
                let latitude = currentLocation.coordinate.latitude
                let longitude = currentLocation.coordinate.longitude
                presenter?.addCode(withName: text, date: dateString, image: imageData, imageBarcode: nil, latitude: latitude, longitude: longitude)
    }
    
    @objc private func shareQrCode() {
        presenter?.shareQr()
    }
    
    @objc private func saveToGalery() {
        presenter?.saveInPhone()
    }
    
    @objc private func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            print("Error saving image to gallery: \(error.localizedDescription)")
        } else {
            presenter?.showAlertSuccefulSave()
        }
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - Functions
    
    private func generateQRCode(from string: String, size: CGSize) -> UIImage? {
        var data: Data?
        if let utf8Data = string.data(using: .utf8) {
            data = utf8Data
        } else if let asciiData = string.data(using: .ascii) {
            data = asciiData
        } else {
            return nil
        }
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
        buttonShare.isHidden = false
        buttonSave.isHidden = false
        return UIImage(cgImage: cgImage)
    }
    
    func saveQr() {
        guard let image = imageQrCode.image else { return }
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
}

    // MARK: - Extensions

extension GenerateScreenViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension GenerateScreenViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    func displayAlertStatusSave(with type: Alert) {
        AlertView.showAlertStatus(type: type, view: self)
    }
}

extension GenerateScreenViewController: GenerateScreenViewProtocol {
    func shareImageQrCode() {
        guard let qrCodeImage = imageQrCode.image else { return }
        let activityViewController = UIActivityViewController(activityItems: [qrCodeImage.jpegData(compressionQuality: 1.0) as Any], applicationActivities: nil)
        activityViewController.completionWithItemsHandler = { (_, completed, _, error) in
            let alert = completed ? Alert.succefulShare : Alert.errorShare
            self.displayAlertStatusSave(with: alert)
            
        }
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    func showAlert(with type: Alert) {
        AlertView.showAlertStatus(type: type, view: self)
    }
    
    func showAlertSaveToGalery(with type: Alert, okHandler: ((UIAlertAction) -> Void)?, cancelHandler: ((UIAlertAction) -> Void)?) {
        AlertView.showAlert(type: type, okHandler: okHandler, cancelHandler: cancelHandler, view: self)
    }
}

//
//  QrScannerViewController.swift
//  QrCodeScanner
//
//  Created by Илья on 12.03.2023.
//

import UIKit
import Lottie
import AVFoundation
import WebKit
import CoreLocation

protocol PDFGeneratorViewProtocol: AnyObject {
    var scanAnimation: LottieAnimationView { get }
    var labelDetected: UILabel { get }
    var qrCodeFrameView: UIView? { get set }
    
    func present(_ viewControllerToPresent: UIViewController, animated: Bool, completion: (() -> Void)?)
    func displayAlert(with type: Alert, okHandler: ((UIAlertAction) -> Void)?, cancelHandler: ((UIAlertAction) -> Void)?)
    func displayAlertStatusSave(with type: Alert)
    func startScan()
    func saveFile(data: NSData)
}

final class QrScannerViewController: UIViewController {
    var presenter: PDFGeneratorPresenterProtocol?
    var capture = AVCaptureSession()
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var qrCodeFrameView: UIView?
    var webView: WKWebView?
    var data = NSData()
    let locationManager = CLLocationManager()
    
    // MARK: - Elements
    
    lazy var scanAnimation: LottieAnimationView = {
        let obj = LottieAnimationView()
        obj.animation = LottieAnimation.named(Strings.ScanAnimationScreen.animationName)
        obj.loopMode = .loop
        obj.isHidden = false
        obj.layer.opacity = 1
        obj.animationSpeed = 0.8
        obj.play()
        return obj
    }()
    
    lazy var labelDetected: UILabel = {
        let label = UILabel()
        label.text = Strings.ScanAnimationScreen.labelDetectedText
        label.textColor = .black
        label.backgroundColor = UIColor(red: 86/255, green: 141/255, blue: 223/255, alpha: 1)
        label.layer.opacity = 0.8
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 25, weight: .bold, width: .compressed)
        return label
    }()
    
    private lazy var progressView: UIProgressView = {
        let progressView = UIProgressView()
        progressView.progressTintColor = .systemBlue
        return progressView
    }()
    
    private lazy var flashButton: UIButton = {
        let button = UIButton()
        let imageOff = UIImage(systemName: "lightbulb.slash")?.resized(to: CGSize(width: 60, height: 60)).withTintColor(.systemBlue)
        let imageOn = UIImage(systemName: "lightbulb.led.fill")?.resized(to: CGSize(width: 60, height: 60)).withTintColor(.systemBlue)
        button.setImage(imageOff, for: .normal)
        button.setImage(imageOn, for: .selected)
        button.addTarget(self, action: #selector(flash), for: .touchUpInside)
        return button
    }()
    
    private lazy var shareButton: UIBarButtonItem = {
        let button = UIBarButtonItem(title: Strings.ScanAnimationScreen.shareButtonText,
                                     style: .plain,
                                     target: self,
                                     action: #selector(saveAsPDF))
        button.isHidden = true
        button.tintColor = .systemBlue
        return button
    }()
    
    // MARK: - Lyfecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupHierarhy()
        makeConstraints()
        navigationItem.rightBarButtonItem = shareButton
        scanView()
        locationManager.requestWhenInUseAuthorization()
    }
    
    // MARK: - Setup
    
    private func setupHierarhy() {
        view.addSubview(labelDetected)
        view.addSubview(scanAnimation)
        view.addSubview(flashButton)
    }
    
    private func makeConstraints() {
        labelDetected.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.bottom.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(50)
            make.left.equalTo(view.snp.left).offset(0)
            make.right.equalTo(view.snp.right).offset(0)
        }
        
        scanAnimation.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.centerY.equalTo(view)
            make.height.equalTo(300)
            make.width.equalTo(350)
        }
        
        flashButton.snp.makeConstraints { make in
            make.bottom.equalTo(labelDetected.snp.top).offset(-20)
            make.left.equalTo(view.snp.left).offset(0)
            make.right.equalTo(view.snp.right).offset(0)
        }
    }
    
    private func setupProgressView() {
        view.addSubview(progressView)
        
        progressView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(0)
            make.left.equalTo(view.snp.left).offset(3)
            make.right.equalTo(view.snp.right).offset(-3)
            make.height.equalTo(6)
        }
    }
    
    // MARK: - Actions
    
    @objc private func saveAsPDF() {
        presenter?.saveAsPDF(data: data)
    }
    
    @objc private func flash(_ sender: UIButton) {
        toggleFlash()
        sender.isSelected = !sender.isSelected
            let image = sender.isSelected ? UIImage(systemName: "lightbulb.led.fill")?.resized(to: CGSize(width: 60, height: 60)).withTintColor(.systemBlue) : UIImage(systemName: "lightbulb.slash")?.resized(to: CGSize(width: 60, height: 60)).withTintColor(.systemBlue)
            sender.setImage(image, for: .normal)
    }
    
    // MARK: - Functions
    
    private func scanView() {
        guard let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            print("Error")
            return
        }
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            capture.addInput(input)
            let captureMetaDataOutput = AVCaptureMetadataOutput()
            capture.addOutput(captureMetaDataOutput)
            captureMetaDataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetaDataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr, .ean8, .ean13]
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: capture)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            videoPreviewLayer?.frame = view.layer.bounds
            view.layer.addSublayer(videoPreviewLayer!)
            progressView.isHidden = false
            DispatchQueue.global().async {
                self.capture.startRunning()
            }
            view.bringSubviewToFront(labelDetected)
            view.bringSubviewToFront(scanAnimation)
            view.bringSubviewToFront(flashButton)
            qrCodeFrameView = UIView()
            
            if let qrcodeFrameView = qrCodeFrameView {
                qrcodeFrameView.layer.borderColor = UIColor.yellow.cgColor
                qrcodeFrameView.layer.borderWidth = 2
                view.addSubview(qrcodeFrameView)
                view.bringSubviewToFront(qrcodeFrameView)
            }
        } catch {
            print(error.localizedDescription)
            return
        }
    }
    
    private func exportAsPDF(from webView: WKWebView?) -> NSData? {
        webView?.exportAsPdfFromWebView()
    }
    
    func saveFile(data: NSData) {
    guard let pdfData = exportAsPDF(from: webView) else { return }
    let activityViewController = UIActivityViewController(activityItems: [pdfData as Any], applicationActivities: nil)
    activityViewController.completionWithItemsHandler = { (_, completed, _, error) in
    let alert = completed ? Alert.succefulSave : Alert.failedSave
    self.displayAlertStatusSave(with: alert)
    }
    self.present(activityViewController, animated: true, completion: nil)
    }
    
    private func openLink(_ link: String) {
        guard Reachability.isConnectedToNetwork() else {
            presenter?.showAlertNoInternet()
            return
        }
        if Reachability.isConnectedToNetwork() == true {
            let webConfiguration = WKWebViewConfiguration()
            let webView = WKWebView(frame: .zero, configuration: webConfiguration)
            
            view.addSubview(webView)
            webView.snp.makeConstraints { make in
            make.edges.equalTo(view.snp.edges)
            }
            guard let url = URL(string: link) ?? nil else { return  }
            let request = URLRequest(url: url)
            let task = URLSession.shared.dataTask(with: request)
            
            webView.load(request)
            self.webView = webView
            shareButton.isHidden = false
            setupProgressView()
            progressView.setProgress(0.1, animated: true)
            webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
            task.resume()
        }
    }
    
    private func toggleFlash() {
        guard let device = AVCaptureDevice.default(for: .video) else { return }
        guard device.hasTorch else { return }

        do {
            try device.lockForConfiguration()
            if device.torchMode == .on {
                device.torchMode = .off
            } else {
                try device.setTorchModeOn(level: 1.0)
            }
            device.unlockForConfiguration()
        } catch {
            print("Error toggling flash: \(error.localizedDescription)")
        }
    }
}

// MARK: - Extensions

extension QrScannerViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard !metadataObjects.isEmpty else {
            qrCodeFrameView?.frame = CGRect.zero
            labelDetected.text = Strings.ScanAnimationScreen.labelDetectedText
            return
        }
        guard let metadataObj = metadataObjects.first as? AVMetadataMachineReadableCodeObject else {
            return
        }
        if metadataObj.type == AVMetadataObject.ObjectType.qr {
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            qrCodeFrameView?.frame = barCodeObject?.bounds ?? .zero
            if let link = metadataObj.stringValue {
                labelDetected.text = link
                openLink(link)
                capture.stopRunning()
                
                let date = Date()
                let dateFormat = DateFormatter()
                dateFormat.locale = Locale(identifier: "ru_RU")
                dateFormat.dateFormat = "d MMMM yyyy 'г.' HH:mm:ss"
                let dateString = dateFormat.string(from: date)
                if let myImage = UIImage(named: "internet") {
                    if let imageData = myImage.pngData() {
                        // Получаем текущие координаты места
                        locationManager.requestWhenInUseAuthorization()
                        if let currentLocation = locationManager.location {
                            let latitude = currentLocation.coordinate.latitude
                            let longitude = currentLocation.coordinate.longitude
                            // Сохраняем данные в Core Data
                            presenter?.addCode(withName: link, date: dateString, image: nil, imageBarcode: imageData, latitude: latitude, longitude: longitude)
                        }
                    }
                }
            }
            if metadataObj.stringValue != nil {
                labelDetected.text = metadataObj.stringValue
            }
        } else if metadataObj.type == AVMetadataObject.ObjectType.ean8 || metadataObj.type == AVMetadataObject.ObjectType.ean13 || metadataObj.type == AVMetadataObject.ObjectType.pdf417 {
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            qrCodeFrameView?.frame = barCodeObject?.bounds ?? .zero
            if let link = metadataObj.stringValue {
                presenter?.openLinkBarCode(barcode: link)
                
                let date = Date()
                let dateFormat = DateFormatter()
                dateFormat.locale = Locale(identifier: "ru_RU")
                dateFormat.dateFormat = "d MMMM yyyy 'г.' HH:mm:ss"
                let dateString = dateFormat.string(from: date)
                if let myImage = UIImage(named: "barcode") {
                    if let imageData = myImage.pngData() {
                        // Получаем текущие координаты места
                        locationManager.requestWhenInUseAuthorization()
                        if let currentLocation = locationManager.location {
                            let latitude = currentLocation.coordinate.latitude
                            let longitude = currentLocation.coordinate.longitude
                            // Сохраняем данные в Core Data
                            presenter?.addCode(withName: link, date: dateString, image: nil, imageBarcode: imageData, latitude: latitude, longitude: longitude)
                        }
                    }
                }
                capture.stopRunning()
            }
            if metadataObj.stringValue != nil {
                labelDetected.text = metadataObj.stringValue
                scanAnimation.stop()
            }
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard keyPath == #keyPath(WKWebView.estimatedProgress), let progress = webView?.estimatedProgress else { return }
        progressView.setProgress(Float(progress), animated: true)
        if progress == 1.0 {
            progressView.removeFromSuperview()
            webView?.removeObserver(self, forKeyPath: "estimatedProgress")
        }
    }
}

extension QrScannerViewController: PDFGeneratorViewProtocol {
    
    func displayAlert(with type: Alert, okHandler: ((UIAlertAction) -> Void)?, cancelHandler: ((UIAlertAction) -> Void)?) {
        AlertView.showAlert(type: type, okHandler: okHandler, cancelHandler: cancelHandler, view: self)
    }
    
    func displayAlertStatusSave(with type: Alert) {
        AlertView.showAlertStatus(type: type, view: self)
    }
    
    func startScan() {
        DispatchQueue.global().async {
            self.capture.startRunning()
        }
    }
}

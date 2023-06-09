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

final class QrScannerViewController: UIViewController, UIPopoverPresentationControllerDelegate {
    var presenter: PDFGeneratorPresenterProtocol?
    var capture = AVCaptureSession()
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var qrCodeFrameView: UIView?
    var webView: WKWebView?
    var data = NSData()
    let locationManager = CLLocationManager()
    var linkToOpen: String?
    let options = ["Поделиться ссылкой", "Открыть в браузере", "Сохранить как PDF"]
    
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
        label.backgroundColor = UIColor.customBlue
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
        let buttonEdgeInsets = UIEdgeInsets(top: -30, left: -30, bottom: -20, right: -20)
        let imageOff = UIImage(systemName: Strings.ScanAnimationScreen.flashButtonOff)?
            .resized(to: CGSize(width: 50, height: 50))
            .withTintColor(.systemBlue)
        let imageOn = UIImage(systemName: Strings.ScanAnimationScreen.flashButtonOn)?
            .resized(to: CGSize(width: 50, height: 50))
            .withTintColor(.systemGreen)
        button.setImage(imageOff, for: .normal)
        button.setImage(imageOn, for: .selected)
        button.addTarget(self, action: #selector(flash), for: .touchUpInside)
        button.hitTestEdgeInsets = buttonEdgeInsets
        return button
    }()
    
    private lazy var slider: UISlider = {
        let slider = UISlider()
        let thumbImage = UIImage(named: Strings.ScanAnimationScreen.thumbImage)?
            .resized(to: CGSize(width: 35, height: 30))
        slider.minimumValue = 1.0
        slider.maximumValue = 10.0
        slider.minimumTrackTintColor = UIColor.customBlue
        slider.setThumbImage(thumbImage, for: .normal)
        slider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
        return slider
    }()
    
    private lazy var dropdownButton: UIBarButtonItem = {
        let button = UIBarButtonItem(title: "Options", style: .plain, target: self, action: #selector(showDropdownMenu))
        button.image = UIImage(systemName: Strings.ScanAnimationScreen.toolBarRigthButton)
        return button
    }()
    
    // MARK: - Lyfecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupHierarhy()
        makeConstraints()
        configureToolbar()
        scanView()
        locationManager.requestWhenInUseAuthorization()
    }
    
    // MARK: - UIPopoverPresentationControllerDelegate
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    // MARK: - Setup
    
    private func setupHierarhy() {
        view.addSubview(labelDetected)
        view.addSubview(scanAnimation)
        view.addSubview(flashButton)
        view.addSubview(slider)
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
            make.top.equalTo(view.snp.top).offset(10)
            make.trailing.equalTo(view.snp.trailing).offset(-10)
            make.height.width.equalTo(50)
        }
        
        slider.snp.makeConstraints { make in
            make.bottom.equalTo(labelDetected.snp.top).offset(-20)
            make.left.equalTo(view.snp.left).offset(20)
            make.right.equalTo(view.snp.right).offset(-20)
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
    
    @objc private func flash(_ sender: UIButton) {
        toggleFlash()
        sender.isSelected = !sender.isSelected
        let image = sender.isSelected ? UIImage(systemName: Strings.ScanAnimationScreen.flashButtonOff)?.resized(to: CGSize(width: 60, height: 60)).withTintColor(.systemBlue) : UIImage(systemName: Strings.ScanAnimationScreen.flashButtonOn)?.resized(to: CGSize(width: 60, height: 60)).withTintColor(.systemBlue)
        sender.setImage(image, for: .normal)
    }
    
    @objc private func sliderValueChanged(_ sender: UISlider) {
        let zoomFactor = sender.value
        guard let captureDevice = AVCaptureDevice.default(for: .video) else { return }
        do {
            try captureDevice.lockForConfiguration()
            defer { captureDevice.unlockForConfiguration() }
            captureDevice.videoZoomFactor = CGFloat(zoomFactor)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    @objc private func closeNewView(_ sender: UIButton) {
        if let newView = self.view.subviews.last,
           let blurEffectView = self.view.subviews.filter({ $0 is UIVisualEffectView }).last as? UIVisualEffectView {
            UIView.animate(withDuration: 0.3, animations: {
                newView.alpha = 0
                self.view.backgroundColor = .white
                blurEffectView.alpha = 0
            }) { _ in
                blurEffectView.removeFromSuperview()
                newView.removeFromSuperview()
            }
            UIView.animate(withDuration: 0.5, animations: {
                newView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
                newView.alpha = 0
                DispatchQueue.global().async {
                    self.capture.startRunning()
                }
                self.qrCodeFrameView?.frame = CGRect.zero
                self.labelDetected.text = Strings.ScanAnimationScreen.labelDetectedText
            }) { (completion: Bool) in
                print("OK")
            }
        }
    }
    
    @objc private func copyUrl() {
        UIPasteboard.general.string = labelDetected.text
        presenter?.showAlertCopyUrl()
    }
    
    @objc private func openLinkButtonTapped() {
        guard let link = self.linkToOpen else {
            return
        }
        self.openLink(link)
    }
    
    @objc private func showDropdownMenu() {
        let dropdownMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        for (index, option) in options.enumerated() {
            let action = UIAlertAction(title: option, style: .default, handler: { [weak self] _ in
                self?.handleOptionSelected(at: index)
            })
            dropdownMenu.addAction(action)
        }
        dropdownMenu.addAction(UIAlertAction(title: "Закрыть", style: .cancel, handler: nil))
        dropdownMenu.popoverPresentationController?.barButtonItem = dropdownButton
        present(dropdownMenu, animated: true, completion: nil)
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
            view.layer.addSublayer(videoPreviewLayer ?? AVCaptureVideoPreviewLayer())
            progressView.isHidden = false
            DispatchQueue.global().async {
                self.capture.startRunning()
            }
            view.bringSubviewToFront(labelDetected)
            view.bringSubviewToFront(scanAnimation)
            view.bringSubviewToFront(flashButton)
            view.bringSubviewToFront(slider)
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
    
    private func saveAsPDF() {
        presenter?.saveAsPDF(data: data)
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
    
    private func shareUrl() {
        let activityVC = UIActivityViewController(activityItems: [labelDetected.text ?? ""], applicationActivities: nil)
        present(activityVC, animated: true, completion: nil)
    }
    
    private func openLink(_ link: String) {
        guard Reachability.isConnectedToNetwork() else {
            presenter?.showAlertNoInternet()
            return
        }
        let webConfiguration = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: webConfiguration)
        view.addSubview(webView)
        let toolbar = UIToolbar()
        view.addSubview(toolbar)
        webView.snp.makeConstraints { make in
            make.top.equalTo(toolbar.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
        toolbar.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(view)
        }
        guard let url = URL(string: link) ?? nil else { return  }
        let request = URLRequest(url: url)
        let task = URLSession.shared.dataTask(with: request)
        
        webView.load(request)
        self.webView = webView
        navigationItem.rightBarButtonItem?.isHidden = false
        setupProgressView()
        progressView.setProgress(0.1, animated: true)
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
        task.resume()
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
    
    private func generateQRCode(from string: String, size: CGSize) -> UIImage? {
        guard let data = string.data(using: .utf8) ?? string.data(using: .ascii) else {
            return nil
        }
        guard let qrFilter = CIFilter(name: "CIQRCodeGenerator") else {
            return nil
        }
        qrFilter.setValue(data, forKey: "inputMessage")
        qrFilter.setValue("Q", forKey: "inputCorrectionLevel")
        guard let qrCodeImage = qrFilter.outputImage else {
            return nil
        }
        let scaleX = size.width / qrCodeImage.extent.size.width
        let scaleY = size.height / qrCodeImage.extent.size.height
        let scale = min(scaleX, scaleY)
        let scaledImage = qrCodeImage.transformed(by: CGAffineTransform(scaleX: scale, y: scale))
        guard let cgImage = CIContext(options: nil).createCGImage(scaledImage, from: scaledImage.extent) else {
            return nil
        }
        return UIImage(cgImage: cgImage)
    }
    
    private func handleOptionSelected(at index: Int) {
        switch index {
        case 0:
            shareUrl()
        case 1:
            openLink()
        case 2:
            saveAsPDF()
        default:
            break
        }
    }
    
    private func openLink() {
        presenter?.openBrowser(link: labelDetected.text ?? "")
    }
    
    private func showNewViewForQr(description: String) {
        let scanCodeView = UIView(frame: CGRect(x: 0, y: 0, width: 350, height: 450))
        scanCodeView.backgroundColor = UIColor.systemGray4
        scanCodeView.alpha = 1
        scanCodeView.layer.cornerRadius = 10
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 190, height: 190))
        imageView.center = CGPoint(x: scanCodeView.bounds.midX, y: scanCodeView.bounds.midY - 100)
        if let qrCodeImage = generateQRCode(from: description, size: CGSize(width: 190, height: 190)) {
            let qrCodeImageView = UIImageView(image: qrCodeImage)
            qrCodeImageView.center = CGPoint(x: scanCodeView.bounds.width / 2, y: 150)
            scanCodeView.addSubview(qrCodeImageView)
        }
        
        let descriptionLabel = UILabel(frame: CGRect(x: 10, y: imageView.frame.maxY + 20, width: scanCodeView.bounds.width - 20, height: 100))
        descriptionLabel.text = description
        descriptionLabel.textAlignment = .center
        descriptionLabel.numberOfLines = 0
        scanCodeView.addSubview(descriptionLabel)
        
        let buttonWidth: CGFloat = 150
        let buttonHeight: CGFloat = 50
        let buttonSpacing: CGFloat = 20
        let buttonY: CGFloat = scanCodeView.bounds.height - buttonHeight - 20
        let buttonXOffset = (scanCodeView.bounds.width - buttonWidth * 2 - buttonSpacing) / 2
        
        let copyurlButton = UIButton(frame: CGRect(x: buttonXOffset, y: buttonY, width: buttonWidth, height: buttonHeight))
        copyurlButton.backgroundColor = UIColor.blue
        copyurlButton.setTitle(Strings.ScanAnimationScreen.titleCopyNewWindow, for: .normal)
        copyurlButton.addTarget(self, action: #selector(copyUrl), for: .touchUpInside)
        copyurlButton.layer.cornerRadius = 20
        scanCodeView.addSubview(copyurlButton)
        
        let openBrowserButton = UIButton(frame: CGRect(x: copyurlButton.frame.maxX + buttonSpacing, y: buttonY, width: buttonWidth, height: buttonHeight))
        openBrowserButton.backgroundColor = UIColor.blue
        openBrowserButton.setTitle(Strings.ScanAnimationScreen.titleOpenLinkNewWindow, for: .normal)
        openBrowserButton.addTarget(self, action: #selector(openLinkButtonTapped), for: .touchUpInside)
        openBrowserButton.layer.cornerRadius = 20
        scanCodeView.addSubview(openBrowserButton)
        self.linkToOpen = description
        
        let closeButton = UIButton(frame: CGRect(x: scanCodeView.bounds.width - 50, y: 10, width: 40, height: 40))
        closeButton.setImage(UIImage(systemName: Strings.ScanAnimationScreen.closeButtonNewWindow), for: .normal)
        closeButton.tintColor = .black
        closeButton.addTarget(self, action: #selector(closeNewView), for: .touchUpInside)
        scanCodeView.addSubview(closeButton)
        
        self.view.addSubview(scanCodeView)
        
        let blurEffect = UIBlurEffect(style: .regular)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        
        view.addSubview(blurEffectView)
        view.addSubview(scanCodeView)
        
        scanCodeView.alpha = 0
        UIView.animate(withDuration: 0.3) {
            scanCodeView.alpha = 1
        }
        
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.0, options: .curveEaseInOut, animations: {
            scanCodeView.center = self.view.center
            scanCodeView.transform = CGAffineTransform.identity
        }, completion: nil)
    }
    
    private func configureToolbar() {
        navigationItem.rightBarButtonItem = dropdownButton
        navigationItem.rightBarButtonItem?.isHidden = true
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
            guard let link = metadataObj.stringValue else { return }
            labelDetected.text = link
            showNewViewForQr(description: link)
            capture.stopRunning()
            let date = Date()
            let dateString = DateFormatter.localizedDateString(from: date)
            guard let image = generateQRCode(from: link, size: CGSize(width: 300, height: 300)),
                  let imageData = image.pngData() else { return }
            locationManager.requestWhenInUseAuthorization()
            guard let currentLocation = locationManager.location else { return }
            
            let latitude = currentLocation.coordinate.latitude
            let longitude = currentLocation.coordinate.longitude
            
            presenter?.addCode(withName: link, date: dateString, image: nil, imageBarcode: imageData, latitude: latitude, longitude: longitude)
            if metadataObj.stringValue != nil {
                labelDetected.text = metadataObj.stringValue
            }
        } else if metadataObj.type == AVMetadataObject.ObjectType.ean8 || metadataObj.type == AVMetadataObject.ObjectType.ean13 || metadataObj.type == AVMetadataObject.ObjectType.pdf417 {
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            qrCodeFrameView?.frame = barCodeObject?.bounds ?? .zero
            guard let link = metadataObj.stringValue else { return }
                presenter?.openLinkBarCode(barcode: link)
                let date = Date()
                let dateString = DateFormatter.localizedDateString(from: date)
                guard let myImage = UIImage(named: Strings.ScanAnimationScreen.imageForBarcode),
                      let imageData = myImage.pngData(),
                      let currentLocation = locationManager.location else {
                    capture.stopRunning()
                    return
                }
                let latitude = currentLocation.coordinate.latitude
                let longitude = currentLocation.coordinate.longitude
                presenter?.addCode(withName: link, date: dateString, image: nil, imageBarcode: imageData, latitude: latitude, longitude: longitude)
                capture.stopRunning()

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

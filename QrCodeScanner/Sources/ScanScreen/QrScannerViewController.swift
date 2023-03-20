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
    
    // MARK: - Elements
    
    lazy var scanAnimation: LottieAnimationView = {
        let obj = LottieAnimationView()
        obj.animation = LottieAnimation.named(Strings.ScanAnimationScreen.animationName)
        obj.loopMode = .loop
        obj.isHidden = false
        obj.layer.opacity = 1
        obj.animationSpeed = 1.7
        obj.play()
        return obj
    }()
    
    lazy var labelDetected: UILabel = {
        let label = UILabel()
        label.text = Strings.ScanAnimationScreen.labelDetectedText
        label.textColor = .black
        label.backgroundColor = .lightGray
        label.layer.opacity = 0.7
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 25, weight: .bold, width: .compressed)
        return label
    }()
    
    private lazy var progressView: UIProgressView = {
        let progressView = UIProgressView()
        progressView.progressTintColor = .systemBlue
        return progressView
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
    }
    
    // MARK: - Setup
    
    private func setupHierarhy() {
        view.addSubview(labelDetected)
        view.addSubview(scanAnimation)
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
            }
            if metadataObj.stringValue != nil {
                labelDetected.text = metadataObj.stringValue
            }
        } else if metadataObj.type == AVMetadataObject.ObjectType.ean8 || metadataObj.type == AVMetadataObject.ObjectType.ean13 || metadataObj.type == AVMetadataObject.ObjectType.pdf417 {
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            qrCodeFrameView?.frame = barCodeObject?.bounds ?? .zero
            if let link = metadataObj.stringValue {
                presenter?.openLinkBarCode(barcode: link)
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
        AlertView.showAlertStatusSave(type: type, view: self)
    }
    
    func startScan() {
        DispatchQueue.global().async {
            self.capture.startRunning()
        }
    }
}

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
    func showAlert(title: String, message: String)
    func present(_ viewControllerToPresent: UIViewController, animated: Bool, completion: (() -> Void)?)
}

class QrScannerViewController: UIViewController {
    var presenter: PDFGeneratorPresenterProtocol?
    var capture = AVCaptureSession()
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var qrCodeFrameView: UIView?
    var webView: WKWebView?
    
    // MARK: - Elements
    
    lazy var scanAnimation: LottieAnimationView = {
        let obj = LottieAnimationView()
        obj.animation = LottieAnimation.named(Strings.ScanAnimationScreen.animationName)
        obj.loopMode = .loop
        obj.isHidden = false
        obj.layer.opacity = 0.6
        obj.animationSpeed = 0.8
        obj.play()
        return obj
    }()
    
    lazy var labelDetected: UILabel = {
        let label = UILabel()
        label.text = Strings.ScanAnimationScreen.labelDetectedText
        label.textColor = .black
        label.backgroundColor = .lightGray
        label.layer.opacity = 0.8
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 25, weight: .bold, width: .compressed)
        return label
    }()
    
    lazy var progressView: UIProgressView = {
        let progressView = UIProgressView()
        progressView.progressTintColor = .green
        return progressView
    }()
    
    lazy var shareButton: UIBarButtonItem = {
        let button = UIBarButtonItem(title: Strings.ScanAnimationScreen.shareButtonText,
                                     style: .plain,
                                     target: self,
                                     action: #selector(saveAsPDF))
        button.isHidden = true
        button.tintColor = .orange
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
    
    func setupHierarhy() {
        view.addSubview(labelDetected)
        view.addSubview(scanAnimation)
    }
    
    func makeConstraints() {
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
            make.height.width.equalTo(300)
        }
    }
    
    func setupProgressView() {
        view.addSubview(progressView)
        
        progressView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            make.left.equalTo(view.snp.left).offset(3)
            make.right.equalTo(view.snp.right).offset(-3)
            make.height.equalTo(15)
        }
    }
    
    // MARK: - Actions
    
    @objc func saveAsPDF() {
        presenter?.saveAsPDF(from: webView)
    }
    
    // MARK: - Functions
    
    func scanView() {
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
            captureMetaDataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
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
    
    func openLink(_ link: String) {
        if Reachability.isConnectedToNetwork() == true {
            let webConfiguration = WKWebViewConfiguration()
            let webView = WKWebView(frame: .zero, configuration: webConfiguration)
            webView.navigationDelegate = self
            
            view.addSubview(webView)
            webView.snp.makeConstraints { make in
                make.top.equalTo(view.snp.top)
                make.left.equalTo(view.snp.left)
                make.right.equalTo(view.snp.right)
                make.bottom.equalTo(view.snp.bottom)
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
            capture.stopRunning()
        } else {
            presenter?.showAlertNoInternet()
        }
    }
}

// MARK: - Extensions

extension QrScannerViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRect.zero
            labelDetected.text = Strings.ScanAnimationScreen.labelDetectedText
            return
        }
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        if metadataObj.type == AVMetadataObject.ObjectType.qr {
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            qrCodeFrameView?.frame = barCodeObject!.bounds
            if let link = metadataObj.stringValue {
                labelDetected.text = link
                // TODO: очередь
                openLink(link)
            }
            if metadataObj.stringValue != nil {
                labelDetected.text = metadataObj.stringValue
            }
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(WKWebView.estimatedProgress) {
            guard let progress = webView?.estimatedProgress else { return  }
            progressView.setProgress(Float(progress), animated: true)
            if progress == 1.0 {
                progressView.removeFromSuperview()
                webView?.removeObserver(self, forKeyPath: "estimatedProgress")
            }
        }
    }
}

extension QrScannerViewController: WKNavigationDelegate {
    
}

extension QrScannerViewController: PDFGeneratorViewProtocol {
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

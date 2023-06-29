//
//  ScanningQrCodeDetailScreen.swift
//  QrCodeScanner
//
//  Created by Илья on 23.03.2023.
//

import UIKit
protocol ScanningQrCodeDetailScreenProtocol: AnyObject {
    func setupDetailedView(name: String, date: String?, image: Data?)
}

class ScanningQrCodeDetailScreen: UIViewController {
    var presenter: ScanningCodeDetailProtocol?
    
    // MARK: - Elements
    
    private lazy var background: UIImageView = {
        let obj = UIImageView(image: UIImage(named: Strings.GenerateScreen.background))
        return obj
    }()
    
    private lazy var nameUrl: UILabel = {
        let text = UILabel()
        text.textColor = .black
        text.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        text.text = ""
        text.textAlignment = .center
        text.numberOfLines = 2
        text.lineBreakMode = .byCharWrapping
        return text
    }()
    
    private lazy var dateScan: UILabel = {
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
    
    private lazy var buttonOpenLink: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: Strings.DetailScreenScanCode.buttonOpenLink), for: .normal)
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.2
        button.layer.shadowOffset = .zero
        button.layer.shadowRadius = 10
        button.addTarget(self, action: #selector(openLink), for: .touchUpInside)
        return button
    }()
    
    private lazy var buttonSearch: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: Strings.DetailScreenScanCode.search), for: .normal)
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.2
        button.layer.shadowOffset = .zero
        button.layer.shadowRadius = 10
        button.addTarget(self, action: #selector(searchInBrowser), for: .touchUpInside)
        return button
    }()
    
    private lazy var viewOnMap: UIButton = {
        let button = UIButton()
        let image = UIImage(systemName: Strings.DetailScreenScanCode.viewOnMap)?
            .resized(to: CGSize(width: 30, height: 30)).withTintColor(UIColor.customBlueDark)
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(viewMap), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lyfecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupHierarhy()
        makeConstraints()
        presenter?.setUpParametersCode()
        hideButton()
    }
    
    // MARK: - Setup
    
    private func setupHierarhy() {
        view.addSubview(background)
        view.addSubview(nameUrl)
        view.addSubview(dateScan)
        view.addSubview(imageQrCode)
        view.addSubview(buttonOpenLink)
        view.addSubview(buttonSearch)
        view.addSubview(viewOnMap)
    }
    
    private func makeConstraints() {
        background.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        nameUrl.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.top.equalToSuperview().offset(100)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().inset(16)
        }
        
        dateScan.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.top.equalTo(nameUrl.snp.bottom).offset(5)
            make.height.equalTo(20)
        }
        
        imageQrCode.snp.makeConstraints { make in
            make.top.equalTo(nameUrl.snp.bottom).offset(50)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(300)
        }
        
        viewOnMap.snp.makeConstraints { make in
            make.top.equalTo(imageQrCode.snp.bottom).offset(30)
            make.centerX.equalTo(view)
            make.height.equalTo(50)
        }
        
        buttonOpenLink.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.bottom.equalTo(view.snp.bottom).offset(-150)
            make.height.width.equalTo(100)
        }
        
        buttonSearch.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.bottom.equalTo(view.snp.bottom).offset(-150)
            make.height.width.equalTo(100)
        }
    }
    
    // MARK: - Function
    
    func hideButton() {
        if let labelText = nameUrl.text, labelText.hasPrefix("http://") || labelText.hasPrefix("https://") {
            buttonSearch.isHidden = true
        } else {
            buttonOpenLink.isHidden = true
        }
    }
    
    // MARK: - Action
    
    @objc func openLink() {
        presenter?.openLink(url: nameUrl.text ?? "")
    }
    
    @objc func searchInBrowser() {
        presenter?.searchInBrowser(url: nameUrl.text ?? "")
    }
    
    @objc func viewMap() {
        presenter?.goToMap()
    }
}

    // MARK: - Extension

extension ScanningQrCodeDetailScreen: ScanningQrCodeDetailScreenProtocol {
    func setupDetailedView(name: String, date: String?, image: Data?) {
        nameUrl.text = name
        dateScan.text = date
        imageQrCode.image = UIImage(data: image ?? Data())
    }
}

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
        return text
    }()
    
   private lazy var dateScan: UILabel = {
        let text = UILabel()
        text.textColor = .black
        text.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        text.text = ""
        return text
    }()
    
    // MARK: - Lyfecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupHierarhy()
        makeConstraints()
        presenter?.setUpParametersCode()
    }
    
    // MARK: - Setup
    
    private func setupHierarhy() {
        view.addSubview(background)
        view.addSubview(nameUrl)
        view.addSubview(dateScan)
    }
    
    private func makeConstraints() {
        background.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        nameUrl.snp.makeConstraints { make in
            make.top.equalTo(view.snp.top).offset(100)
            make.left.equalTo(view.snp.left).offset(10)
            make.right.equalTo(view.snp.right).offset(-10)
            make.height.equalTo(40)
        }
        
        dateScan.snp.makeConstraints { make in
            make.top.equalTo(nameUrl.snp.top).offset(40)
            make.left.equalTo(view.snp.left).offset(10)
            make.right.equalTo(view.snp.right).offset(-10)
            make.height.equalTo(40)
        }
    }
}

extension ScanningQrCodeDetailScreen: ScanningQrCodeDetailScreenProtocol {
    func setupDetailedView(name: String, date: String?, image: Data?) {
        nameUrl.text = name
        dateScan.text = date
    }
}

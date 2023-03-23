//
//  TableViewCell.swift
//  QrCodeScanner
//
//  Created by Илья on 22.03.2023.
//

import UIKit

class TableViewCell: UITableViewCell {
    
    static let identifier = "cell"
    
    // MARK: - Elements
    
     lazy var textName: UILabel = {
        let label = UILabel()
        label.textColor = .black
        return label
    }()
    
     lazy var date: UILabel = {
        let label = UILabel()
        label.textColor = .black
        return label
    }()
    
    lazy var image: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = nil
        return imageView
    }()
    
    // MARK: - Initializers
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupHierarchy()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupHierarchy() {
        addSubview(image)
        addSubview(textName)
        addSubview(date)
    }
    
    private func setupLayout() {
        image.snp.makeConstraints { make in
            make.centerY.equalTo(contentView)
            make.left.equalTo(contentView).offset(15)
            make.width.height.equalTo(50)
        }
        
        textName.snp.makeConstraints { make in
            make.left.equalTo(image.snp.right).offset(20)
            make.top.equalTo(snp.top).offset(10)
            make.right.equalTo(snp.right).offset(-20)
            make.height.equalTo(20)
        }
        
        date.snp.makeConstraints { make in
            make.left.equalTo(image.snp.right).offset(20)
            make.right.equalTo(snp.right).offset(-60)
            make.top.equalTo(textName.snp.bottom).offset(10)
            make.height.equalTo(20)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        textName.text = nil
        date.text = nil
    }
    
    func configure(with code: QrCode) {
        textName.text = code.name
        date.text = code.date
        if let imageData = code.imageBarcode, let image = UIImage(data: imageData) {
            self.image.image = image
        } else {
            self.image.image = nil
        }
    }
}




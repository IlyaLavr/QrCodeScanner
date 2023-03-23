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
    
    // MARK: - Initializers
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
//        self.accessoryType = .disclosureIndicator
        setupHierarchy()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupHierarchy() {
        addSubview(textName)
        addSubview(date)
    }
    
    private func setupLayout() {
        textName.snp.makeConstraints { make in
                make.left.equalTo(snp.left).offset(20)
                make.right.equalTo(snp.right).offset(-60)
                make.centerY.equalTo(snp.centerY)
        }
        
        date.snp.makeConstraints { make in
            make.left.equalTo(snp.left).offset(20)
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
    }
}




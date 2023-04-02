//
//  HistoryScreenViewController.swift
//  QrCodeScanner
//
//  Created by Илья on 22.03.2023.
//

import UIKit

protocol HistoryScreenViewProtocol: AnyObject {
    func reloadTable()
}

class HistoryScreenViewController: UIViewController, HistoryScreenViewProtocol {
    var presenter: HistoryScreenPresenterProtocol?
    let items = ["Отсканированные", "Сгененированные"]
    
    // MARK: - Elements
    
    lazy var segmentControl: UISegmentedControl = {
        let segmentView =  UISegmentedControl(items: items)
        segmentView.selectedSegmentIndex = 0
        segmentView.backgroundColor = .white
        segmentView.addTarget(self, action: #selector(selectSaveCode), for: .valueChanged)
        return segmentView
    }()
    
    private lazy var background: UIImageView = {
        let obj = UIImageView(image: UIImage(named: Strings.GenerateScreen.background))
        return obj
    }()
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.backgroundColor = nil
        tableView.tintColor = .blue
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TableViewCell.self, forCellReuseIdentifier: TableViewCell.identifier)
        tableView.register(ImageTableViewCell.self, forCellReuseIdentifier: ImageTableViewCell.identifier)
        return tableView
    }()
    
    private lazy var button: UIButton = {
        let button = UIButton()
        button.setTitle("Посмотреть на карте", for: .normal)
        button.tintColor = .black
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.2
        button.layer.shadowOffset = .zero
        button.layer.shadowRadius = 10
        button.addTarget(self, action: #selector(goToMap), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lyfecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupHierarhy()
        makeConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        presenter?.fetchAllQrCodes()
    }
    
    // MARK: - Setup
    
    private func setupHierarhy() {
        view.addSubview(background)
        view.addSubview(tableView)
        view.addSubview(segmentControl)
        view.addSubview(button)
    }
    
    private func makeConstraints() {
        background.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        segmentControl.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            make.left.equalTo(view.snp.left).offset(20)
            make.right.equalTo(view.snp.right).offset(-20)
            make.height.equalTo(30)
        }
        
        button.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(segmentControl.snp.bottom).offset(12)
            make.height.equalTo(30)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(segmentControl.snp.bottom).offset(20)
            make.left.right.equalTo(view)
            make.bottom.equalTo(view)
        }
    }
    
    // MARK: - Actions
    
    @objc func selectSaveCode() {
        UISelectionFeedbackGenerator().selectionChanged()

        switch segmentControl.selectedSegmentIndex {
        case 0:
            tableView.dataSource = self
            reloadTable()
            
        case 1:
            reloadTable()
            tableView.dataSource = self
        default:
            tableView.reloadData()
            tableView.dataSource = nil
        }
    }
    
    @objc func goToMap() {
        presenter?.goToMapScreen()
    }
    
    // MARK: - Functions
    
    func reloadTable() {
        tableView.reloadData()
    }
}

extension HistoryScreenViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if segmentControl.selectedSegmentIndex == 0 {
            guard let model = presenter?.fetchQrCodesWithoutImage()[indexPath.row] else {
                return UITableViewCell()
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCell.identifier, for: indexPath) as? TableViewCell
            cell?.configure(with: model)
            cell?.accessoryType = .disclosureIndicator
            return cell ?? UITableViewCell()
        } else {
            guard let model = presenter?.fetchQrCodesWithImage()[indexPath.row] else {
                return UITableViewCell()
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: ImageTableViewCell.identifier, for: indexPath) as? ImageTableViewCell
            cell?.configure(with: model)
            cell?.accessoryType = .disclosureIndicator
            return cell ?? UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return segmentControl.selectedSegmentIndex == 0 ? presenter?.countOfQrCodeWhithoutImage() ?? 0 : presenter?.countOfQrCodeWithImage() ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}

extension HistoryScreenViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        segmentControl.selectedSegmentIndex == 0 ? presenter?.showDetail(code: indexPath) : presenter?.showDetailGeneratedCode(code: indexPath)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            segmentControl.selectedSegmentIndex == 0 ? presenter?.deleteCode(index: indexPath) : presenter?.deleteCodeWithImage(index: indexPath)
        }
    }
}

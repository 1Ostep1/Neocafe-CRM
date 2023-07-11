//
//  BranchViewController.swift
//  ClientApp
//
//  Created by Рамазан Юсупов on 7/11/21.
//

import UIKit
import CoreLocation
import MapKit

class BranchViewController: BaseViewController {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        label.textColor = .black
        label.text = "Филиалы"
        return label
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.delegate = self
        view.dataSource = self
        view.registerReusable(CellType: BranchCell.self)
        view.backgroundColor = Asset.clientBackround.color
        view.refreshControl = refreshControl
        return view
    }()
    
    private lazy var refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(loadDetails), for: .touchUpInside)
        return control
    }()
    
    private var branches: [BranchDTO] = [] {
        didSet {
            DispatchQueue.main.async {            
                self.collectionView.reloadData()
            }
        }
    }
    
    // MARK: - Injection
    private let viewModel: BranchViewModelType
    
    init(vm: BranchViewModelType) {
        viewModel = vm
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
        loadDetails()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadDetails()
    }
    
    private func setUp() {
        setUpSubviews()
        setUpConstaints()
    }
    
    private func setUpSubviews() {
        view.addSubview(titleLabel)
        view.addSubview(collectionView)
    }
    
    private func setUpConstaints () {
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(15)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(35)
        }
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.bottom.trailing.leading.equalToSuperview()
        }
    }
    
    @objc
    private func loadDetails() {
        withRetry(viewModel.getBranches) { [weak self] res in
            if case .success(let result) = res {
                self?.branches = result
            }
        }
    }
    
    private func resendTapped(with link: String?) {
        guard
            let urlString = link,
            let url = URL(string: urlString) else {
            return
        }
        UIApplication.shared.open(url)
    }
}

// MARK: - Delegate Datasource
extension BranchViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int { 1 }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { return branches.count }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueIdentifiableCell(BranchCell.self, for: indexPath)
        cell.delegate = self
        cell.display(branch: branches[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize { CGSize(width: screenWidth, height: 195) }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize { CGSize(width: screenWidth, height: 40) }
}

extension BranchViewController: BranchCellDelegate {
    func resendTo2Gis(with data: BranchDTO) {
        let alert = UIAlertController(title: "Мы переведем вас в 2ГИС",
                                      message: "Вы сможете быстро сориентироваться и найти быстрый маршрут к нам! Ждем вас!",
                                      preferredStyle: .alert)
        let resendAction = UIAlertAction(title: "Перейти", style: .default) { [weak self] _ in
            self?.resendTapped(with: data.link2gis)
        }
        alert.addAction(resendAction)
        alert.addAction(UIAlertAction(title: "Остаться", style: .cancel))
        present(alert, animated: true)
    }
}

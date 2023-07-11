//
//  ProfileViewController.swift
//  ClientApp
//
//  Created by Рамазан Юсупов on 7/11/21.
//

import UIKit

class ProfileViewController: BaseViewController {
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
        label.text = "Ramazan"
        return label
    }()
    
    private lazy var editButton: UIButton = {
        let button = UIButton()
        button.setImage(Asset.pencil.image, for: .normal)
        button.tintColor = .darkGray
        button.addTarget(self, action: #selector(editProfileTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: view.frame.width, height: 105)
        layout.minimumLineSpacing = 10
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.delegate = self
        view.dataSource = self
        view.registerReusableView(ViewType: BonusItemCell.self,  type: .UICollectionElementKindSectionHeader)
        view.registerReusable(CellType: ProfileOrderCell.self)
        view.registerReusableView(ViewType: Header.self, type: .UICollectionElementKindSectionHeader)
        view.backgroundColor = Asset.clientBackround.color
        return view
    }()
    
    // MARK: - Injection
    var viewModel: ProfileViewModelType!
    
    private var bonus = 0
    private var currentOrders: [HistoryDTO] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    private var completedOrders: [HistoryDTO] = []{
        didSet {
            collectionView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
        configureNavBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getCurrentOrders()
        getComletedOrders()
        getBonuses()
    }
    
    init(vm: ProfileViewModelType) {
        viewModel = vm
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUp() {
        setUpSubviews()
        setUpConstaints()
    }
    
    private func setUpSubviews() {
        view.addSubview(titleLabel)
        view.addSubview(editButton)
        view.addSubview(collectionView)
    }
    
    private func setUpConstaints () {
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(5)
            make.leading.equalToSuperview().offset(16)
            make.width.greaterThanOrEqualTo(30)
            make.height.equalTo(35)
        }
        editButton.snp.makeConstraints { make in
            make.top.equalTo(titleLabel).offset(3)
            make.leading.equalTo(titleLabel.snp.trailing).offset(10)
            make.width.height.equalTo(25)
        }
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(5)
            make.bottom.trailing.leading.equalToSuperview()
        }
    }
    
    private func configureNavBar() {
        navigationController?.navigationBar.tintColor = .black
        navigationController?.navigationBar.barTintColor = Asset.clientBackround.color
        navigationItem.title = "Профиль"
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: Asset.signOut.image,
            style: .done,
            target: self,
            action: #selector(logOutTapped)
        )
    }
    
    // MARK: - Requests
    private func getBonuses() {
        viewModel.getBonuses { [weak self] res in
            if case .success(let bonus) = res {
                self?.bonus = bonus
            }
        }
    }
    
    private func getCurrentOrders() {
        withRetry(viewModel.getCurrentOrders) { [weak self] res in
            if case .success(let items) = res {
                self?.currentOrders = items
            }
        }
    }
    
    private func getComletedOrders() {
        withRetry(viewModel.getCompletedOrders) { [weak self] res in
            if case .success(let items) = res {
                self?.completedOrders = items
            }
        }
    }
    
    // MARK: - OBJC functions
    @objc
    private func logOutTapped() {
        viewModel.logOut()
        dismiss(animated: true)
    }
    
    @objc
    private func editProfileTapped() {
        let profileEditVC = InjectionService.resolve(controller: ProfileEditViewController.self)
        navigationController?.pushViewController(profileEditVC, animated: true)
    }
    
    @objc private func bonusViewTapped() {
        let alert = UIAlertController(
            title: "Бонусы",
            message: "Накапливайте бонусы и совершайте выгодные для Вас заказы! 1 бонус = 1 сом",
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Хорошо", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - Collection delegate datasource
extension ProfileViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        3
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return 0
        } else if section == 1 {
            return currentOrders.count
        }
        return completedOrders.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueIdentifiableCell(ProfileOrderCell.self, for: indexPath)
        if indexPath.section == 0 {
            let cell = UICollectionViewCell()
            return cell
        } else if indexPath.section == 1 {
            cell.display(currentOrders[indexPath.row])
            return cell
        } else {
            cell.display(completedOrders[indexPath.row])
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeuReusableView(ViewType: Header.self, type: .UICollectionElementKindSectionHeader, for: indexPath)
        if indexPath.section == 0 {
            let headerView = collectionView.dequeuReusableView(ViewType: BonusItemCell.self, type: .UICollectionElementKindSectionHeader, for: indexPath)
            headerView.delegate = self
            headerView.display(bonus: bonus)
            return headerView
        } else if indexPath.section == 1 {
            header.display(with: .current)
            return header
        }
        header.display(with: .closed)
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section == 0 {
            return CGSize(width: 170, height: 130)
        }
        return CGSize(width: 170, height: 60)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}

extension ProfileViewController: BonusItemCellDelegate {
    func openView() {
        let alert = UIAlertController(
            title: "Бонусы",
            message: "Накапливайте бонусы и совершайте выгодные для Вас заказы! \n 1 бонус = 1 сом",
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Хорошо", style: .default))
        present(alert, animated: true)
    }
}

//
//  DetailsDishViewController.swift
//  ClientApp
//
//  Created by Рамазан Юсупов on 3/12/21.
//

import UIKit

protocol Dish {
    var description: String { get }
    var id: Int { get }
    var imageUrl: String? { get }
    var name: String { get }
    var price: Double { get }
}

extension DishDTO: Dish { }

extension FullCategoryDTO: Dish {
    var imageUrl: String? { imagesUrl }
}

class DetailsDishViewController: BaseViewController {
    private lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleToFill
        return view
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hexString: "#414141")
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 24, weight: .medium)
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.numberOfLines = 0
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        return label
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let coll = UICollectionView(frame: .zero, collectionViewLayout: layout)
        coll.registerReusable(CellType: PopularItemCell.self)
        coll.registerReusableView(ViewType: FooterView.self, type: .UICollectionElementKindSectionFooter)
        coll.registerReusableView(ViewType: HeaderView.self, type: .UICollectionElementKindSectionHeader)
        coll.delegate = self
        coll.dataSource = self
        coll.backgroundColor = UIColor(hexString: "#414141")
        return coll
    }()
    
    private var popularDishes: [FullCategoryDTO] = [] {
        didSet {
            products = popularDishes.map { item in
                return ListOrderDetailsDto(
                    stockId: item.dishId,
                    urlImage: item.dishUrl,
                    generalAdditionalId: nil,
                    name: item.dishName,
                    price: Int(item.dishPrice),
                    quantity: item.count
                )
            }
        }
    }
    
    private var products: [ListOrderDetailsDto] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    
    var selectedDish: Dish?
    
    // MARK: - Injection
    private var viewModel: MainViewModelType
    
    init(vm: MainViewModelType) {
        viewModel = vm
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("error with coder")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
        configureDish()
        getPopularDishes()
        addObserver()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        contentView.roundCorners(corners: [.topLeft, .topRight], radius: 20)
    }
    
    private func setUp() {
        setUpSubviews()
        setUpConstaints()
    }
    
    private func setUpSubviews() {
        view.addSubview(imageView)
        view.addSubview(contentView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(collectionView)
    }
    
    private func setUpConstaints() {
        imageView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(imageView.snp.width)
        }
        contentView.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(-40)
            make.trailing.bottom.leading.equalToSuperview()
        }
        titleLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(25)
        }
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(6)
            make.leading.trailing.equalTo(titleLabel)
            make.height.greaterThanOrEqualTo(30)
        }
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(30)
            make.bottom.leading.trailing.equalToSuperview()
        }
    }
    
    private func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(getProducts), name: .init("com.ostep.ClientApp.saved"), object: nil)
    }
    
    @objc
    private func getProducts() {
        Task {
            do {
                let products: [ListOrderDetailsDto] = try await FirestoreManager.shared.fetchAllData(from: .basket)
                self.products = products
            } catch {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    private func configureDish() {
        guard let dish = selectedDish else { return }
        imageView.sd_setImage(with: dish.imageUrl?.url)
        titleLabel.text = dish.name
        descriptionLabel.text = dish.description
    }
    
    // MARK: - Requests
    private func getPopularDishes() {
        withRetry(viewModel.getPopularDishes) { [weak self] result in
            if case .success(let res) = result {
                self?.popularDishes = res
            }
        }
    }
}

extension DetailsDishViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return popularDishes.count > 3 ? 3 : popularDishes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueIdentifiableCell(PopularItemCell.self, for: indexPath)
        let dish = products[indexPath.row]
        cell.display(cell: dish)
        cell.delegate = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: screenWidth - 40, height: 90)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let headerView = collectionView.dequeuReusableView(ViewType: HeaderView.self, type: .UICollectionElementKindSectionHeader, for: indexPath)
            headerView.display(with: "Приятное дополнение")
            return headerView
        default:
            let footerView = collectionView.dequeuReusableView(ViewType: FooterView.self, type: .UICollectionElementKindSectionFooter, for: indexPath)
            return footerView
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        CGSize(width: screenWidth, height: 80)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        CGSize(width: screenWidth, height: 80)
    }
    
}

extension DetailsDishViewController: PopularItemDelegate {
    func updateItems(with items: ListOrderDetailsDto) {
        FirestoreManager.shared.saveTo(collection: .basket, id: items.stockId, data: items)
    }
}


// MARK: - HeaderView
extension DetailsDishViewController {
    class HeaderView: UICollectionReusableView {
        private lazy var headerTitle: UILabel = {
            let label = UILabel()
            label.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
            label.textColor = .white
            return label
        }()
        
        override func layoutSubviews() {
            super.layoutSubviews()
            setUp()
        }
        
        private func setUp() {
            addSubview(headerTitle)
            headerTitle.snp.makeConstraints { make in
                make.top.leading.equalToSuperview().offset(16)
                make.bottom.trailing.equalToSuperview().offset(-16)
            }
        }
        
        func display(with text: String) {
            headerTitle.text = text
        }
    }
}

extension String {
    var url: URL? {
        URL(string: self)
    }
}

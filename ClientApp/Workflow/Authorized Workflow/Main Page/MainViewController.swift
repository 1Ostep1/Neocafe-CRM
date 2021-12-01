//
//  MainViewController.swift
//  ClientApp
//
//  Created by Рамазан Юсупов on 7/11/21.
//

import UIKit
import AVFoundation

class MainViewController: BaseViewController, UICollectionViewDelegate {
    
    enum Section: String, CaseIterable {
        case header = ""
        case category = "Наше меню"
        case popular = "Популярное"
    }
    
    enum Item: Hashable {
        static func == (lhs: MainViewController.Item, rhs: MainViewController.Item) -> Bool {
            return true
        }
        
        case popular(FullCategoryDTO)
        case category(CategoryDTO)
    }
    
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: generateLayout())
        collectionView.registerReusableView(ViewType: BonusItemCell.self, type: .UICollectionElementKindSectionHeader)
        collectionView.registerReusable(CellType: CategoryItemCell.self)
        collectionView.registerReusable(CellType: PopularItemCell.self)
        collectionView.registerReusableView(ViewType: HeaderItemView.self, type: .UICollectionElementKindSectionHeader)
        collectionView.backgroundColor = Colors.background.color
        collectionView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    var dataSource: UICollectionViewDiffableDataSource<Section, Item>! = nil
    
    // MARK: - Injection
    var viewModel: MainViewModelType
    
    private var popularDishes: [FullCategoryDTO] = [] {
        didSet {
            buildPopularDishes()
        }
    }
    private var categories: [CategoryDTO] = [] {
        didSet {
            buildCategory()
        }
    }
    private var bonus: Int = 0 {
        didSet {
//            buildBonusView()
        }
    }
    
    private var snapShot: Snapshot = {
        var snp = Snapshot()
        snp.appendSections([.header, .category, .popular])
        return snp
    }()
    
    init(vm: MainViewModelType) {
        viewModel = vm
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        getBonuses()
//        getCategories()
//        getPopularDishes()
        setUp()
     }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getCategories()
        getBonuses()
        getPopularDishes()
    }
    
    private func setUp() {
        setUpSubviews()
    }
    
    private func setUpSubviews() {
        view.addSubview(collectionView)
    }
    
    // MARK: - Requests
    private func getPopularDishes() {
        withRetry(viewModel.getPopularDishes) { [weak self] result in
            if case .success(let res) = result {
                self?.popularDishes = res
            }
        }
    }
    
    private func getCategories() {
        withRetry(viewModel.getCategoriesDish) { [weak self] result in
            if case .success(let res) = result {
                self?.categories = res
            }
        }
    }
    
    private func getBonuses() {
        viewModel.getBonuses { [weak self] res in
            if case .success(let bonus) = res {
                self?.bonus = bonus
            }
        }
    }
}

// MARK: - Collection Datasource
extension MainViewController {
    
    func buildPopularDishes() {
        self.snapShot.appendItems(self.popularDishes.map { Item.popular($0) }, toSection: .popular)
        self.configureDataSource()
    }
    
    func buildCategory() {
//        DispatchQueue.main.async {
//            self.snapShot.appendItems(self.categories.map { Item.category($0) }, toSection: .category)
//            self.configureDataSource()
//        }
    }
    
//    func buildBonusView() {
//        self.snapShot.appendItems([Item.bonus(self.bonus)], toSection: .header)
//        self.configureDataSource()
//    }
    
    func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, Item> (collectionView: collectionView) { [weak self]
            (collectionView: UICollectionView, indexPath: IndexPath, item: Item) -> UICollectionViewCell? in
            guard let `self` = self else { return nil }
             switch item {
                case .category:
                 let cell = collectionView.dequeueIdentifiableCell(CategoryItemCell.self, for: indexPath)
                 cell.display(cell: self.categories[indexPath.row])
                 return cell
                case .popular:
                 let cell = collectionView.dequeueIdentifiableCell(PopularItemCell.self, for: indexPath)
                 cell.display(cell: self.popularDishes[indexPath.row])
                 return cell
             }
        }
        
        dataSource.supplementaryViewProvider = { (
            collectionView: UICollectionView,
            kind: String,
            indexPath: IndexPath) -> UICollectionReusableView? in
            
            if indexPath.section == 0 {
                let headerView = collectionView.dequeuReusableView(ViewType: BonusItemCell.self, type: .UICollectionElementKindSectionHeader, for: indexPath)
                headerView.display(bonus: self.bonus)
                return headerView
            }
            let supplementaryView = collectionView.dequeuReusableView(ViewType: HeaderItemView.self, type: .UICollectionElementKindSectionHeader, for: indexPath)
            supplementaryView.label.text = Section.allCases[indexPath.section].rawValue
            return supplementaryView
        }
        let snapshot = snapShot
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    func generateLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            
            let sectionLayoutKind = Section.allCases[sectionIndex]
            switch sectionLayoutKind {
                case .header:
                    return self.generateHeaderLayout()
                case .popular:
                    return self.generatePopularItemsLayout()
                case .category:
                    return self.generateCategoryItemsLayout()
            }
        }
        return layout
    }
    
    func generateHeaderLayout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .absolute(130))
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalWidth(1/2.4)
        )
        
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitem: item,
            count: 1
        )
        
        group.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 16, trailing: 16)
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .none
        section.contentInsets = NSDirectionalEdgeInsets(top: 24, leading: 0, bottom: 0, trailing: 0)
        return section
    }
    
    func generateCategoryItemsLayout() -> NSCollectionLayoutSection {
        let doubleItemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.5),
            heightDimension: .fractionalHeight(1.0)
        )
        
        let doubleItem = NSCollectionLayoutItem(layoutSize: doubleItemSize)
        
        doubleItem.contentInsets = NSDirectionalEdgeInsets(
            top: 8,
            leading: 8,
            bottom: 8,
            trailing: 8
        )
        
        let doubleGroupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalWidth(1/2.4)
        )
        
        let doubleGroup = NSCollectionLayoutGroup.horizontal(
            layoutSize: doubleGroupSize,
            subitem: doubleItem,
            count: 2
        )
        
        let tripletItem = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1/3),
                heightDimension: .fractionalHeight(1)))
        
        tripletItem.contentInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: 8,
            bottom: 0,
            trailing: 8
        )
        
        let tripletGroup = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalWidth(1/3)),
            subitems: [tripletItem, tripletItem, tripletItem])
        
        let nestedGroup = NSCollectionLayoutGroup.vertical(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalWidth(0.75)),
            subitems: [
                doubleGroup,
                tripletGroup
            ]
        )
        
        nestedGroup.contentInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: 8,
            bottom: 0,
            trailing: 8
        )
        
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(44)
        )
        
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        sectionHeader.pinToVisibleBounds = true
        sectionHeader.zIndex = 2
       
        let section = NSCollectionLayoutSection(group: nestedGroup)
        section.boundarySupplementaryItems = [sectionHeader]
        return section
    }
    
    func generatePopularItemsLayout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalWidth(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalWidth(0.2594752187)
        )
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitem: item, count: 1)
        group.contentInsets = NSDirectionalEdgeInsets(top: 9, leading: 16, bottom: 9, trailing: 16)
        
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(44)
        )
        
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        sectionHeader.pinToVisibleBounds = true
        sectionHeader.zIndex = 2
        let section = NSCollectionLayoutSection(group: group)
        section.boundarySupplementaryItems = [sectionHeader]
        section.orthogonalScrollingBehavior = .none
        
        return section
    }
}

//
//  MainViewController.swift
//  ClientApp
//
//  Created by Рамазан Юсупов on 7/11/21.
//

import UIKit
import AVFoundation

class MainViewController: BaseViewController {
    enum Section: String, CaseIterable {
        case header = ""
        case category = "Наше меню"
        case popular = "Популярное"
    }
    
    enum Item: Hashable {
        case popular(ListOrderDetailsDto)
        case category(CategoryDTO)
    }
    
    typealias Datasource = UICollectionViewDiffableDataSource<Section, Item>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>
    
    private lazy var refreshControl: UIRefreshControl = {
        let rControl = UIRefreshControl()
        rControl.tintColor = Asset.clientOrange.color
        rControl.addTarget(self, action: #selector(reloadMainPage), for: .valueChanged)
        return rControl
    }()
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.registerReusableView(ViewType: BonusItemCell.self, type: .UICollectionElementKindSectionHeader)
        collectionView.registerReusable(CellType: CategoryItemCell.self)
        collectionView.registerReusable(CellType: PopularItemCell.self)
        collectionView.registerReusableView(ViewType: HeaderItemView.self, type: .UICollectionElementKindSectionHeader)
        collectionView.registerReusableView(ViewType: FooterView.self, type: .UICollectionElementKindSectionFooter)
        collectionView.backgroundColor = Asset.clientBackround.color
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.delegate = self
        collectionView.refreshControl = refreshControl
        return collectionView
    }()
    
    // MARK: - Injection
    var viewModel: MainViewModelType
    
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
            applySnapshot()
        }
    }
    private var categories: [CategoryDTO] = []
    private var oldCategories: [CategoryDTO] = []

    private var bonus: Int = 0
    private var dataSource: UICollectionViewDiffableDataSource<Section, Item>!
    
    init(vm: MainViewModelType) {
        viewModel = vm
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        reloadMainPage()
        setUp()
        makeDataSource()
        addObserver()
    }
    
    private func setUp() {
        view.addSubview(collectionView)
    }
    
    private func applySnapshot(animatingDifferene: Bool = true) {
        var snapshot = Snapshot()
        snapshot.appendSections([.header, .category, .popular])
        snapshot.appendItems(categories.map({ Item.category($0) }), toSection: .category)
        snapshot.appendItems(products.map({ Item.popular($0) }), toSection: .popular)
        dataSource.apply(snapshot, animatingDifferences: animatingDifferene)
    }
    
    private func reloadSection(section: [Section]) {
        var snapshot = Snapshot()
        if #available(iOS 16.0, *) {
            if snapshot.sectionIdentifiers.contains(section) {
                snapshot.reloadSections(section)
            }
        } else {}
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    private func makeDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, Item>(
            collectionView: collectionView,
            cellProvider: { collectionView, indexPath, itemIdentifier in
                if case .category(let model) = itemIdentifier {
                    let cell = collectionView.dequeueIdentifiableCell(CategoryItemCell.self, for: indexPath)
                    cell.display(cell: model)
                    return cell
                } else if case .popular(let model) = itemIdentifier {
                    let cell = collectionView.dequeueIdentifiableCell(PopularItemCell.self, for: indexPath)
                    cell.display(cell: model)
                    cell.delegate = self
                    return cell
                } else { return nil }
            })
        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            switch kind {
            case UICollectionView.elementKindSectionHeader:
                if indexPath.section == 0 {
                    let headerView = collectionView.dequeuReusableView(ViewType: BonusItemCell.self, type: .UICollectionElementKindSectionHeader, for: indexPath)
                    headerView.display(bonus: self.bonus)
                    return headerView
                }
                let supplementaryView = collectionView.dequeuReusableView(ViewType: HeaderItemView.self, type: .UICollectionElementKindSectionHeader, for: indexPath)
                supplementaryView.label.text = Section.allCases[indexPath.section].rawValue
                return supplementaryView
            case UICollectionView.elementKindSectionFooter:
                let footer = collectionView.dequeuReusableView(ViewType: FooterView.self, type: .UICollectionElementKindSectionFooter, for: indexPath)
                return footer
            default:
                let footer = collectionView.dequeuReusableView(ViewType: FooterView.self, type: .UICollectionElementKindSectionFooter, for: indexPath)
                return footer
            }
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
    
    // MARK: - Requests
    private func getPopularDishes() {
        withRetry(viewModel.getPopularDishes) { [weak self] result in
            if case .success(let res) = result {
                self?.popularDishes = res
                self?.applySnapshot(animatingDifferene: false)
            }
        }
    }
    
    private func getCategories() {
        withRetry(viewModel.getCategoriesDish) { [weak self] result in
            if case .success(let res) = result {
                self?.categories = res
                self?.oldCategories = res
                self?.applySnapshot(animatingDifferene: false)
            }
        }
    }
    
    private func getBonuses() {
        viewModel.getBonuses { [weak self] res in
            if case .success(let bonus) = res {
                self?.bonus = bonus
                self?.reloadSection(section: [.header])
            }
        }
    }
    
    @objc
    private func reloadMainPage() {
        getBonuses()
        getCategories()
        getPopularDishes()
        Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { [weak self] _ in
            self?.collectionView.refreshControl?.endRefreshing()
        }
    }
}

// MARK: - Delegate Datasource
extension MainViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            let controller = CategoryPageMenuController()
            switch categories[indexPath.row].name {
            case "Десерты": controller.categoryIndex = 1
            case "Кофе": controller.categoryIndex = 2
            case "Чаи": controller.categoryIndex = 3
            case "Коктейли": controller.categoryIndex = 4
            case "Выпечка": controller.categoryIndex = 5
            default: controller.categoryIndex = 1
            }
            navigationController?.pushViewController(controller, animated: true)
        } else {
            let controller = InjectionService.resolve(controller: DetailsDishViewController.self)
            controller.selectedDish = popularDishes[indexPath.row]
            navigationController?.pushViewController(controller, animated: true)
        }
    }
}


// MARK: - Collection Layout
extension MainViewController {
    func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex, _) -> NSCollectionLayoutSection? in
            let sectionLayoutKind = Section.allCases[sectionIndex]
            switch sectionLayoutKind {
            case .header: return self.generateHeaderLayout()
            case .popular: return self.generatePopularItemsLayout()
            case .category: return self.generateCategoryItemsLayout()
            }
        }
        return layout
    }
    
    func generateHeaderLayout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .absolute(1),
            heightDimension: .absolute(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .absolute(1),
            heightDimension: .absolute(1)
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitem: item,
            count: 1
        )
        
        group.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 16, trailing: 16)
        
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(130)
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
            heightDimension: .fractionalWidth(0.26)
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
        
        let footerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .absolute(100)
        )
        
        let sectionFooter = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: footerSize,
            elementKind: UICollectionView.elementKindSectionFooter,
            alignment: .bottom
        )
        
        let section = NSCollectionLayoutSection(group: group)
        section.boundarySupplementaryItems = [sectionHeader, sectionFooter]
        section.orthogonalScrollingBehavior = .none
        
        return section
    }
}

extension MainViewController: PopularItemDelegate {
    func updateItems(with items: ListOrderDetailsDto) {
        FirestoreManager.shared.saveTo(collection: .basket, id: items.stockId, data: items)
    }
}

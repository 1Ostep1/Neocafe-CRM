//
//  BasketViewController.swift
//  ClientApp
//
//  Created by Рамазан Юсупов on 7/11/21.
//

import UIKit

class BasketViewController: BaseViewController {
    enum TypeSelected {
        case takeaway
        case intheCafe
    }
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        label.textColor = .black
        label.text = "Корзина"
        return label
    }()
    
    private lazy var historyOfOrdersButton: UIButton = {
        let button = UIButton()
        button.setTitle("История", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        button.setTitleColor(Asset.clientOrange.color, for: .normal)
        button.addTarget(self, action: #selector(historyTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: screenWidth, height: 90)
        layout.minimumLineSpacing = 10
        layout.footerReferenceSize = CGSize(width: screenWidth, height: 300)
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.delegate = self
        view.dataSource = self
        view.registerReusable(CellType: OrderCell.self)
        view.registerReusableView(ViewType: OrderButtonsView.self, type: .UICollectionElementKindSectionFooter)
        view.backgroundColor = Asset.clientBackround.color
        return view
    }()
    
    private let emptyView: EmptyView = {
        let view = EmptyView()
        return view
    }()
    
    private var bonusTextField = UITextField()
    
    private var sum = 0
    private var dishesInBasket: [ListOrderDetailsDto] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    // MARK: - injection
    private var viewModel: BasketViewModelType
    
    init(vm: BasketViewModelType) {
        viewModel = vm
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getBonuses()
        Task {
            let dishesInBasket = try! await viewModel.getDishes()
            self.dishesInBasket = dishesInBasket
            emptyView.isHidden = !dishesInBasket.isEmpty
            collectionView.isHidden = dishesInBasket.isEmpty
        }
        
        collectionView.reloadData()
    }
    
    private func setUp() {
        setUpSubviews()
        setUpConstaints()
        emptyView.menuTapped = handleMenuTap
    }
    
    private func setUpSubviews() {
        view.addSubview(titleLabel)
        view.addSubview(historyOfOrdersButton)
        view.addSubview(collectionView)
        view.addSubview(emptyView)
    }
    
    private func setUpConstaints() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(5)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(35)
        }
        historyOfOrdersButton.snp.makeConstraints { make in
            make.top.equalTo(titleLabel).offset(14)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(20)
            make.width.equalTo(85)
        }
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(5)
            make.bottom.trailing.leading.equalToSuperview()
        }
        emptyView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    private func addSubstractBonuses(amount: Int) {
        viewModel.addSubstractBonuses(amount: amount) { [weak self] res in
            if case .success(let bonus) = res {
                self?.viewModel.bonuses = bonus
                self?.getBonuses()
            }
        }
    }
    
    private func observeNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(reloadBasketView), name: .init("com.ostep.addedToBasket"), object: nil)
    }
    
    // MARK: - OBJC functions
    @objc
    private func reloadBasketView() {
        collectionView.reloadData()
    }
    
    @objc
    private func historyTapped() {
        let historyVC = InjectionService.resolve(controller: HistoryOrderViewController.self)
        navigationController?.pushViewController(historyVC, animated: true)
    }
    
    private func handleMenuTap() {
        tabBarController?.selectedIndex = 0
    }
    
    private func orderInfo(sum: Int) {
        viewModel.setSum(sum)
    }
    
    private func getBonuses() {
        viewModel.getBonuses { [weak self] res in
            if case .success(let bonus) = res {
                self?.viewModel.bonuses = bonus
            }
        }
    }
    // MARK: - Handlers
    private func handleOrder() {
        let dishes = dishesInBasket
        let orderType = viewModel.getOrderType()
        let order = OrderDTO(
            branchId: 0,
            listOrderDetailsDto: dishes,
            orderType: orderType.rawValue,
            tableId: 0
        )
        
        viewModel.addOrder(with: order) { _ in
            print("feawsfa")
        }
    }
}

// MARK: - Datasource Delegate
extension BasketViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dishesInBasket.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueIdentifiableCell(OrderCell.self, for: indexPath)
        cell.display(dish: dishesInBasket[indexPath.row])
        cell.orderCount = { [weak self] order in
            FirestoreManager.shared.saveTo(collection: .basket, id: order.stockId, data: order)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeuReusableView(ViewType: OrderButtonsView.self, type: .UICollectionElementKindSectionFooter, for: indexPath)
        view.delegate = self
        view.display(item: viewModel.getSum())
        return view
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}

extension BasketViewController: OrderButtonsViewDelegate {
    func addMoreTap() {
        tabBarController?.selectedIndex = 0
    }
    
    func orderTap() {
        showBonusAlert()
        print("Order tapp")
    }
    
    func orderTypeTap(type: OrderButtonsView.OrderType) {
        viewModel.setOrderType(type)
    }
    
    private func showBonusAlert() {
        let alert = UIAlertController(
            title: "Cписание бонусов",
            message: "У вас есть \(viewModel.bonuses) бонусов, хотите использовать их?",
            preferredStyle: .alert)
        
        alert.addTextField(configurationHandler: configurationTextField)
        alert.addAction(UIAlertAction(title: "Списать", style: .default) { [weak self] action in
            guard
                let self,
                let bonus = Int(self.bonusTextField.text ?? "0"),
                bonus <= self.viewModel.bonuses else {
                return
            }
            self.handleOrder()
            self.addSubstractBonuses(amount: bonus)
        })
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        present(alert, animated: true)
    }
    
    private func configurationTextField(textField: UITextField) {
        self.bonusTextField = textField
        textField.keyboardType = .numberPad
    }
}

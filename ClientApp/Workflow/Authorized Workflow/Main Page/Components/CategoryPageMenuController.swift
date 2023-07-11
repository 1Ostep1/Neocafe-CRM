//
//  CategoryPageMenuController.swift
//  ClientApp
//
//  Created by Рамазан Юсупов on 2/12/21.
//

import UIKit
import XLPagerTabStrip

class CategoryPageMenuController: ButtonBarPagerTabStripViewController {
    private lazy var buttonBar: ButtonBarView = {
        let layout = UICollectionViewFlowLayout()
        let button = ButtonBarView(frame: .zero, collectionViewLayout: layout)
        button.backgroundColor = Asset.clientBackround.color
        return button
    }()
    
    private lazy var containerView1: UIScrollView = {
        let view = UIScrollView()
        view.showsVerticalScrollIndicator = false
        view.showsHorizontalScrollIndicator = false
        view.backgroundColor = Asset.clientBackround.color
        return view
    }()
    
    var isFirstTime = true
    
    override func viewDidLoad() {
        view.addSubview(buttonBar)
        view.addSubview(containerView1)
        buttonBarView = buttonBar
        containerView = containerView1
        buttonBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.trailing.leading.equalToSuperview()
            make.height.equalTo(50)
        }
        containerView1.snp.makeConstraints { make in
            make.top.equalTo(buttonBar.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
        configurePageController()
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isFirstTime {
            isFirstTime = false
            moveToViewController(at: categoryIndex - 1, animated: true)
        }
    }
    
    var categoryIndex = 0
    
    private func configurePageController() {
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.backgroundColor = Asset.clientBackround.color
        settings.style.buttonBarItemBackgroundColor = .clear
        settings.style.buttonBarBackgroundColor = Asset.clientBackround.color
        settings.style.selectedBarBackgroundColor = Asset.clientDarkBackround.color
        settings.style.buttonBarItemFont = UIFont.systemFont(ofSize: 16, weight: .medium)
        settings.style.selectedBarHeight = 2
        settings.style.buttonBarItemTitleColor = .darkGray
        settings.style.buttonBarItemsShouldFillAvailableWidth = false
        settings.style.buttonBarMinimumInteritemSpacing = 2
        settings.style.buttonBarItemLeftRightMargin = 30
    }
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        let desertsController = InjectionService.resolve(controller: CategoryViewController.self)
        desertsController.categoryIndex = 1
        let сoffeeController = InjectionService.resolve(controller: CategoryViewController.self)
        сoffeeController.categoryIndex = 3
        let teaController = InjectionService.resolve(controller: CategoryViewController.self)
        teaController.categoryIndex = 2
        let cocktailsController = InjectionService.resolve(controller: CategoryViewController.self)
        cocktailsController.categoryIndex = 4
        let bakeryController = InjectionService.resolve(controller: CategoryViewController.self)
        bakeryController.categoryIndex = 5
        return [desertsController, сoffeeController, teaController, cocktailsController, bakeryController]
    }
}

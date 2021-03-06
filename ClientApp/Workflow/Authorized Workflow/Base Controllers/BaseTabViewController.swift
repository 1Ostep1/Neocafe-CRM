//
//  BaseTabViewController.swift
//  ClientApp
//
//  Created by Рамазан Юсупов on 7/11/21.
//

import UIKit
import FittedSheets

enum TabBar: CaseIterable {
    case Home
    case Basket
    case QRCode
    case Branch
    case Profile
    
    var tabBarItem: UITabBarItem {
        switch self {
        case .Home: return UITabBarItem(title: nil, image: Asset.house.image, selectedImage: nil)
        case .Basket: return UITabBarItem(title: nil, image: Asset.toteSimple.image, selectedImage: nil)
        case .QRCode: return UITabBarItem(title: nil, image: UIImage(), selectedImage: nil)
        case .Branch: return UITabBarItem(title: nil, image: Asset.mapPin.image, selectedImage: nil)
        case .Profile: return UITabBarItem(title: nil, image: Asset.user.image, selectedImage: nil)
        }
    }
    
    var viewController: UINavigationController {
        var vc = UINavigationController()
        switch self {
        case .Home: vc = UINavigationController(rootViewController: DIService.shared.getVc(MainViewController.self))
        case .Basket: vc = UINavigationController(rootViewController: DIService.shared.getVc(BasketViewController.self))
        case .QRCode: vc = UINavigationController()
        case .Branch: vc = UINavigationController(rootViewController: DIService.shared.getVc(BranchViewController.self))
        case .Profile: vc = UINavigationController(rootViewController: DIService.shared.getVc(ProfileViewController.self))
        }
        
        vc.setNavigationBarHidden(false, animated: false)
        vc.tabBarItem = tabBarItem
        return vc
    }
}

class BaseTabViewController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
        setupMiddleButton()
    }
    
    private func setUp() {
        viewControllers = TabBar.allCases.map({ $0.viewController })
        
        tabBar.itemPositioning = .centered
        tabBar.backgroundImage = UIImage()
        tabBar.shadowImage = UIImage()
        tabBar.tintColor = Asset.clientOrange.color
        tabBar.backgroundColor = Asset.clientBackround.color
        tabBar.itemWidth = (tabBar.frame.size.width / 5)
    }
    
    func setupMiddleButton() {
        let menuButton = UIButton(frame: CGRect(x: 0, y: 0, width: 67, height: 67))
        var menuButtonFrame = menuButton.frame
        menuButtonFrame.origin.y = view.bounds.height - menuButtonFrame.height - 30
        menuButtonFrame.origin.x = view.bounds.width/2 - menuButtonFrame.size.width/2
        menuButton.frame = menuButtonFrame
        
        menuButton.backgroundColor = Asset.clientOrange.color
        menuButton.layer.cornerRadius = menuButtonFrame.height/2
        view.addSubview(menuButton)
        
        menuButton.setImage(Asset.qrCode.image, for: .normal)
        menuButton.tintColor = .white
        menuButton.addTarget(self, action: #selector(menuButtonAction), for: .touchUpInside)
        
        view.layoutIfNeeded()
    }
    
    // MARK: - Actions
    @objc private func menuButtonAction(sender: UIButton) {
        let qrCodeVC = DIService.shared.getVc(QRCodeViewController.self)
        let controller = SheetViewController(controller: qrCodeVC, sizes: [.percent(0.8)])
        controller.cornerRadius = 20
        present(controller, animated: true)
    }
}

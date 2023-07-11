//
//  BaseRegistrationViewController.swift
//  ClientApp
//
//  Created by Рамазан Юсупов on 3/11/21.
//

import UIKit
import SnapKit
import Swinject

class BaseRegistrationViewController: UIViewController {

    private let registrationIcon: UIImageView = {
        let view = UIImageView()
        view.image = Asset.igNeocafe.image
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
    }
    
    private func setUp() {
        let backItem = UIBarButtonItem()
        backItem.title = " "
        navigationItem.backBarButtonItem = backItem
        view.backgroundColor = Asset.clientBackround.color
        setUpSubviews()
        setUpConstaints()
    }
    
    private func setUpSubviews() {
        view.addSubview(registrationIcon)
    }
    
    private func setUpConstaints () {
        registrationIcon.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(60)
            make.centerX.equalToSuperview()
            make.height.equalTo(100)
            make.width.equalTo(180)
        }
    }
}

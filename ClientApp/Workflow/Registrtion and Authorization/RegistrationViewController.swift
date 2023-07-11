//
//  RegistrationViewController.swift
//  ClientApp
//
//  Created by Рамазан Юсупов on 2/12/21.
//

import UIKit

class RegistrationViewController: BaseRegistrationViewController {
    
    var viewModel: SplashViewModelType!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if viewModel.isAuthorized {
            let controller = BaseTabViewController()
            controller.modalPresentationStyle = .overFullScreen
            present(controller, animated: true)
        } else {
            let controller = InjectionService.resolve(controller: SplashViewController.self)
            controller.modalPresentationStyle = .overFullScreen
            present(controller, animated: true)
        }
    }
    
    init(viewModel vm: SplashViewModelType) {
        viewModel = vm
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

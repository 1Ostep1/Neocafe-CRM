//
//  HomePageAssembly.swift
//  ClientApp
//
//  Created by Iusupov Ramazan on 26/2/22.
//

import Foundation
import Swinject
import SwinjectAutoregistration

class HomePageAssembly: Assembly {
    func assemble(container: Container) {
        container.autoregister(MainViewModelType.self, initializer: MainViewModel.init)
            .inObjectScope(.transient)
        
        container.register(MainViewController.self) { r in
            MainViewController(vm: r~>)
        }.inObjectScope(.container)
        
        container.register(CategoryViewController.self) { r in
            CategoryViewController(vm: r~>)
        }.inObjectScope(.transient)
        
        container.register(DetailsDishViewController.self) { r in
            DetailsDishViewController(vm: r~>)
        }.inObjectScope(.graph)
        
        container.register(MainViewController.self) { r in
            MainViewController(vm: r~>)
        }.inObjectScope(.container)
    }
}

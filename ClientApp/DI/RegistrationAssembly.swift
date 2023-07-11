//
//  RegistrationAssembly.swift
//  ClientApp
//
//  Created by Рамазан Юсупов on 4/11/21.
//

import Foundation
import Swinject
import SwinjectAutoregistration

class RegistrationAssembly: Assembly {
    func assemble(container: Container) {
        container.autoregister(PhoneRegistrationViewModelType.self, initializer: PhoneRegistrationViewModel.init)
            .inObjectScope(.transient)
        
        container.register(PhoneRegistrationViewController.self) { r in
            PhoneRegistrationViewController(vm: r~>)
        }.inObjectScope(.container)
        
        container.register(BirthdayViewController.self) { r in
            BirthdayViewController(vm: r~>)
        }.inObjectScope(.container)
        
        container.register(PhoneConfirmationViewController.self) { r in
            PhoneConfirmationViewController(vm: r~>)
        }.inObjectScope(.container)
    }
}

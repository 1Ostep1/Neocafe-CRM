//
//  DIService.swift
//  ClientApp
//
//  Created by Iusupov Ramazan on 12/5/22.
//

import Swinject
import SwinjectAutoregistration
import SwinjectStoryboard
import UIKit

struct InjectionService {
    static func resolve<T: UIViewController>(controller type: T.Type) -> T {
        SwinjectStoryboard.defaultContainer.resolve(type)!
    }
}

//
//  CommonConstants.swift
//  ClientApp
//
//  Created by Рамазан Юсупов on 4/11/21.
//

import Foundation

enum CommonConstants {
    
    // MARK: - Base
    static let baseUrl = URL(string: "https://neocafe.herokuapp.com")!
    
    // MARK: - Registration
    enum Registration {
        static func registerUser() -> URL {
            baseUrl.appendingPathComponent("client/registration")
        }
        
        static func confirmCode() -> URL {
            baseUrl.appendingPathComponent("client/activate")
        }
    }
    
    // MARK: - Authorization
    enum Authorization {
        static func authorizeUser() -> URL {
            baseUrl.appendingPathComponent("client/auth")
        }
        
        static func confirmAuthorizationCode() -> URL {
            baseUrl.appendingPathComponent("client/login")
        }
    }
    
    // MARK: - Profile Editing
    enum ProfileEditing {
        static func getUserInfo() -> URL {
            baseUrl.appendingPathComponent("/client/profile/info")
        }
        
        static func setBirthdayToUser() -> URL {
            baseUrl.appendingPathComponent("/client/add-bDate")
        }
        
        static func editProfile() -> URL {
            baseUrl.appendingPathComponent("/client/profile/edit")
        }
    }
    
    // MARK: - Categories
    enum Menu {
        static func getCategories() -> URL {
            baseUrl.appendingPathComponent("/categories/all")
        }
        
        static func getDish(id: Int) -> URL {
            baseUrl.appendingPathComponent("/client/menu/one/get-by-id/\(id)")
        }
        
        static func getMenu(id: Int) -> URL {
            baseUrl.appendingPathComponent("/menu/get-all/\(id)")
        }
        
        static func tableAvailability(tableId: Int) -> URL {
            baseUrl.appendingPathComponent("/table/is-free/\(tableId)")
        }
    }
    
    // MARK: - Orders
    enum Orders {
        static func orderHistory() -> URL {
            baseUrl.appendingPathComponent("/client/orders/history")
        }
        
        static func getPopular() -> URL {
            baseUrl.appendingPathComponent("/client/menu/get-popular")
        }
        
        static func getCategory(id: Int) -> URL {
            baseUrl.appendingPathComponent("/client/menu/all/by-category/\(id)")
        }
        
        static func addNewOrder() -> URL {
            baseUrl.appendingPathComponent("/client/orders/add")
        }
        
        static func getAllOrders() -> URL {
            baseUrl.appendingPathComponent("client/orders/get-all-orders-currentUser")
        }
        
        static func getClosedOrders() -> URL {
            baseUrl.appendingPathComponent("/client/orders/get-completed-orders")
        }
        
        static func getCurrentOrders() -> URL {
            baseUrl.appendingPathComponent("/client/orders/get-curr-order")
        }
        
        static func getAllCategories() -> URL {
            baseUrl.appendingPathComponent("/client/category/all")
        }
        
        static func getDishesFromCategory(id: Int) -> URL {
            baseUrl.appendingPathComponent("/client/menu/one/get-by-id/\(id)")
        }
        
        static func getPopularDishes() -> URL {
            baseUrl.appendingPathComponent("/client/menu/get-popular")
        }
    }
    
    // MARK: - Bonuses
    enum Bonus {
        static func getBonuses() -> URL {
            baseUrl.appendingPathComponent("/client/bonuses/get-amount")
        }
        
        static func addOrSubstractBonuses(amount: Int) -> URL {
            baseUrl.appendingPathComponent("/client/bonuses/subtract/\(amount)")
        }
    }
    
    // MARK: - Branches
    enum Branches {
        static func getBranches() -> URL {
            baseUrl.appendingPathComponent("/client/branches/get-all-up-to-date-info")
        }
    }
}

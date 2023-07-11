//
//  BasketManager.swift
//  ClientApp
//
//  Created by Рамазан Юсупов on 2/12/21.
//

import Foundation

protocol OrderType {
    var dishId: Int { get }
    var dishName: String { get }
    var dishPrice: Double { get }
    var description: String { get }
    var dishUrl: String? { get }
}

protocol BasketManagerType {
    func addNewDish(_ dish: ListOrderDetailsDto)
    func getDishes() async throws -> [ListOrderDetailsDto]
}

class BasketManager: BasketManagerType {
    private let authService: AuthServiceType
    private let webApi: WebApiServiceType
    private let firestoreManager = FirestoreManager.shared
    private var dishesInCart: [ListOrderDetailsDto] = []
    
    init(webApi: WebApiServiceType, authService: AuthServiceType) {
        self.webApi = webApi
        self.authService = authService
    }
    
    func addNewDish(_ dish: ListOrderDetailsDto) {
        if let dishIndex = dishesInCart.firstIndex(where: { $0.stockId == dish.stockId }) {
            dishesInCart[dishIndex].quantity += 1
        } else {
            var dish = dish
            dish.quantity = 1
            dishesInCart.append(dish)
        }
        NotificationCenter.default.post(name: .init("com.ostep.addedToBasket"), object: nil)
    }
    
    func getDishes() async throws -> [ListOrderDetailsDto] {
        return try await firestoreManager.fetchAllData(from: .basket)
    }
}


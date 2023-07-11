//
//  BasketViewModel.swift
//  ClientApp
//
//  Created by Рамазан Юсупов on 7/11/21.
//

import Foundation

protocol BasketViewModelType {
    func getDishes() async throws -> [ListOrderDetailsDto]
    func setSum(_ sum: Int)
    func getSum() -> String
    func setOrderType(_ type: OrderButtonsView.OrderType)
    func getOrderType() -> OrderButtonsView.OrderType
    func getBonuses(completion: @escaping(Result<Int, Error>) -> Void)
    func addOrder(with orderInfo: OrderDTO, completion: @escaping (Result<OrderDTO, Error>) -> Void)
    
    func addSubstractBonuses(amount: Int, completion: @escaping (Result<Int, Error>) -> Void)
    var bonuses: Int { get set }
}

class BasketViewModel: NSObject, BasketViewModelType {
    var authService: AuthServiceType
    var webApi: WebApiServiceType
    var basketManager: BasketManagerType
    var bonuses: Int = 0
    
    private var dishes: [ListOrderDetailsDto] = []
    private var sum = Int.zero
    private var orderType = OrderButtonsView.OrderType.atTheVenue
    
    init(webApi: WebApiServiceType, authService: AuthServiceType, basketManager: BasketManagerType) {
        self.webApi = webApi
        self.authService = authService
        self.basketManager = basketManager
    }
    
    func getDishes() async throws -> [ListOrderDetailsDto] {
        let items = try await basketManager.getDishes()
        dishes = items
        return items
    }
    
    func setSum(_ sum: Int) {
        self.sum = sum
    }
    
    func getSum() -> String {
        let sum = sum == .zero
        ? dishes
            .map { Int($0.price) * $0.quantity }
            .reduce(0, +)
        : self.sum
        
        self.sum = sum
        return String(sum)
    }
    
    func setOrderType(_ type: OrderButtonsView.OrderType) {
        self.orderType = type
    }
    
    func getOrderType() -> OrderButtonsView.OrderType {
        return self.orderType
    }
    
    func getBonuses(completion: @escaping(Result<Int, Error>) -> Void) {
        webApi.getBonuses(completion: completion)
    }
    
    func addOrder(with orderInfo: OrderDTO, completion: @escaping (Result<OrderDTO, Error>) -> Void) {
        webApi.addOrder(with: orderInfo, completion: completion)
    }
    
    func addSubstractBonuses(amount: Int, completion: @escaping (Result<Int, Error>) -> Void) {
        webApi.addSubstractBonuses(amount: amount, completion: completion)
    }
}

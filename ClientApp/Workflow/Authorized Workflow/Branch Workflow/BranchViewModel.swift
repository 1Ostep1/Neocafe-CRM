//
//  BranchViewModel.swift
//  ClientApp
//
//  Created by Рамазан Юсупов on 7/11/21.
//

import Foundation

protocol BranchViewModelType {
    func getBranches(completion: @escaping (Result<[BranchDTO], Error>) -> Void)
    func addOrder(with orderInfo: OrderDTO, completion: @escaping (Result<OrderDTO, Error>) -> Void)
}

class BranchViewModel: NSObject, BranchViewModelType {

    private let webApi: WebApiServiceType
    
    init(webApi: WebApiServiceType) {
        self.webApi = webApi
    }
    
    func getBranches(completion: @escaping (Result<[BranchDTO], Error>) -> Void) {
        webApi.getBranches(completion: completion)
    }
    
    func addOrder(with orderInfo: OrderDTO, completion: @escaping (Result<OrderDTO, Error>) -> Void) {
        webApi.addOrder(with: orderInfo, completion: completion)
    }
}

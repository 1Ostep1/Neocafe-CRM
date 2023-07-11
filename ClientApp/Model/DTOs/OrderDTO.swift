//
//  OrderDTO.swift
//  ClientApp
//
//  Created by Рамазан Юсупов on 28/11/21.
//

import Foundation

struct OrderDTO: Codable {
    let branchId: Int
    let listOrderDetailsDto: [ListOrderDetailsDto]?
    let orderType: String
    let tableId: Int
}

struct ListOrderDetails: Codable {
    let generalAdditionalId: [Int]
    let quantity: Int
    let stockId: Int
}

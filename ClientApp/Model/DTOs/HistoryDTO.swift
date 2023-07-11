//
//  HistoryDTO.swift
//  ClientApp
//
//  Created by Рамазан Юсупов on 1/12/21.
//

import Foundation

struct HistoryDTO: Codable {
    let branchAddress: String
    let branchId: Int
    let branchLink2gis: String
    let branchName: String
    let branchPhoneNumber: String
    let branchWorkingTime: String
    let listOrderDetailsDto: [ListOrderDetailsDto]
    let orderId: Int
    let orderTime: String
    let orderType: String
    let status: String
    let tableId: Int
    let totalPrice: Int
}

struct ListOrderDetailsDto: Codable, Equatable, Hashable {
    static func == (lhs: ListOrderDetailsDto, rhs: ListOrderDetailsDto) -> Bool {
        lhs.stockId == rhs.stockId && lhs.name == rhs.name
    }
    
    let stockId: Int
    let urlImage: String?
    let generalAdditionalId: [GeneralAddition]?
    let name: String
    let price: Int
    var quantity: Int
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(stockId)
    }
}

struct GeneralAddition: Codable {
    let generalAdditionalId: Int
}

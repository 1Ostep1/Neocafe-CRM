//
//  FullOrderInfoElement.swift
//  ClientApp
//
//  Created by Рамазан Юсупов on 28/11/21.
//

import Foundation

struct DishDTO: Codable {
    let description: String
    let generalAdditionals: [GeneralAdditionals]?
    let id: Int
    let imageUrl: String?
    let name: String
    let price: Double
}

extension DishDTO: OrderType {
    var dishId: Int { id }
    var dishName: String { name }
    var dishPrice: Double { price }
    var dishUrl: String? { imageUrl }
}

struct GeneralAdditionals: Codable {
    let id: Int
    let nameProduct: String
    let price: Int
    let typeGeneralAdditional: String
}

struct FullOrderInfoElement: Codable {
    let branchAddress: String
    let branchID: Int
    let branchLink2GIS, branchName, branchPhoneNumber, branchWorkingTime: String
    let listOrderDetailsDto: [ListOrderDetailsDto]
    let orderID: Int
    let orderTime, orderType, status: String
    let tableID, totalPrice: Int

    enum CodingKeys: String, CodingKey {
        case branchAddress
        case branchID = "branchId"
        case branchLink2GIS = "branchLink2gis"
        case branchName, branchPhoneNumber, branchWorkingTime, listOrderDetailsDto
        case orderID = "orderId"
        case orderTime, orderType, status
        case tableID = "tableId"
        case totalPrice
    }
}

typealias FullOrderInfo = [FullOrderInfoElement]

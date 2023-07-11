//
//  CategoryDTO.swift
//  ClientApp
//
//  Created by Рамазан Юсупов on 28/11/21.
//

import Foundation

struct FullCategoryDTO: Codable, Hashable, Equatable {
    private enum CodingKeys : String, CodingKey {
        case category, description, id, imagesUrl, name, price, status, counter
    }
    
    let category: CategoryDTO
    var description: String
    let counter: Int
    let id: Int
    let imagesUrl: String?
    let name: String
    let price: Double
    let status: String
    
    static func ==(lhs: FullCategoryDTO, rhs: FullCategoryDTO) -> Bool{
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension FullCategoryDTO: OrderType {
    var dishId: Int { id }
    var dishPrice: Double { price }
    var sum: Double? { Double(counter * Int(price)) }
    var dishName: String { name }
    var dishUrl: String? { imagesUrl }
    var count: Int {
        get { counter }
        set { _ = counter }
    }
}

struct CategoryDTO: Codable, Hashable, Equatable {
    private enum CodingKeys : String, CodingKey { case id, name, status }
    
    let id: Int
    let name: String
    let status: String
    
    static func ==(lhs: CategoryDTO, rhs: CategoryDTO) -> Bool{
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct CategoryMenuDTO: Codable {
    let name: String
    let price: Double
}

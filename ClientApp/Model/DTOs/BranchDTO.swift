//
//  BranchDTO.swift
//  ClientApp
//
//  Created by Рамазан Юсупов on 23/11/21.
//

import Foundation

struct BranchDTO: Codable {
    
    let branchId: Int
    let name: String
    let address: String
    let phoneNumber: String
    let link2gis: String?
    let workingTime: String
}

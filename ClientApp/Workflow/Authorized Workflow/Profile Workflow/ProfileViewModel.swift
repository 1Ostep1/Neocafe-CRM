//
//  ProfileViewModel.swift
//  ClientApp
//
//  Created by Рамазан Юсупов on 7/11/21.
//

import Foundation

protocol ProfileViewModelType {
    func logOut()
    func getUserInfo(completion: @escaping (Result<UserProfileDTO, Error>) -> Void)
    func editProfile(name: String, birthDate: String, completion: @escaping(Result<Void, Error>) -> Void)
    
    // MARK: - Bonuses
    func getBonuses(completion: @escaping(Result<Int, Error>) -> Void)
    // MARK: - Get orders history
    func getCurrentOrders(completion: @escaping (Result<[HistoryDTO], Error>) -> Void)
    func getCompletedOrders(completion: @escaping (Result<[HistoryDTO], Error>) -> Void)
}

class ProfileViewModel: ProfileViewModelType {
    
    var authService: AuthServiceType
    var webApi: WebApiServiceType
    
    
    init(webApi: WebApiServiceType, authService: AuthServiceType) {
        self.webApi = webApi
        self.authService = authService
    }
    
    func logOut() {
        authService.logout()
    }
    
    func getUserInfo(completion: @escaping (Result<UserProfileDTO, Error>) -> Void) {
        webApi.getUserInfo(completion: completion)
    }
    
    func editProfile(name: String, birthDate: String, completion: @escaping(Result<Void, Error>) -> Void) {
        webApi.editProfile(name: name, birthDate: birthDate, completion: completion)
    }
    
    func getBonuses(completion: @escaping(Result<Int, Error>) -> Void) {
        webApi.getBonuses(completion: completion)
    }
    
    func getCurrentOrders(completion: @escaping (Result<[HistoryDTO], Error>) -> Void) {
        webApi.getCurrentOrders(completion: completion)
    }
    
    func getCompletedOrders(completion: @escaping (Result<[HistoryDTO], Error>) -> Void) {
        webApi.getCompletedOrders(completion: completion)
    }
}

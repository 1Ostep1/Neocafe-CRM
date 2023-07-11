//
//  WebApiService.swift
//  ClientApp
//
//  Created by Рамазан Юсупов on 3/11/21.
//

import Foundation
import Alamofire

protocol WebApiServiceType {
    // MARK: - Registration
    func registerNewUser(user: RegistrationDTO, completion: @escaping (Result<Void, Error>) -> Void)
    func sendConfirmation(for phoneNumber: String, confirmationCode: String, completion: @escaping (Result<JwtInfo, Error>) -> Void)
    
    // MARK: - Authorization
    func authorizeUser(phoneNumber number: AuthorizationDTO, completion: @escaping (Result<Void, Error>) -> Void)
    func confirmAuthCode(for phoneNumber: String, confirmationCode: String, completion: @escaping (Result<JwtInfo, Error>) -> Void)
    
    // MARK: - Person editing
    func getUserInfo(completion: @escaping (Result<UserProfileDTO, Error>) -> Void)
    func setBirthdayToUser(userBDay: BirthdayDTO, completion: @escaping (Result<Void, Error>) -> Void)
    func editProfile(name: String, birthDate: String, completion: @escaping(Result<Void, Error>) -> Void)
    
    // MARK: - Bonuses
    func getBonuses(completion: @escaping (Result<Int, Error>) -> Void)
    func addSubstractBonuses(amount: Int, completion: @escaping (Result<Int, Error>) -> Void)
    
    // MARK: - Branches
    func getBranches(completion: @escaping (Result<[BranchDTO], Error>) -> Void)
    
    // MARK: - Orders
    func addOrders(order: OrderDTO, completion: @escaping (Result<Void, Error>) -> Void)
    func checkTableAvailability(tableId: Int, completion: @escaping (Result<Bool, Error>) -> Void)
    func getAllOrders(completion: @escaping (Result<[OrderDTO], Error>) -> Void)
    func getCompletedOrders(completion: @escaping (Result<[HistoryDTO], Error>) -> Void)
    func getCurrentOrders(completion: @escaping (Result<[HistoryDTO], Error>) -> Void)

    // MARK: - Category
    func getAllCategories(completion: @escaping (Result<[CategoryDTO], Error>) -> Void)
    func getCategoriesDish(categoryId: Int, completion: @escaping (Result<CategoryMenuDTO, Error>) -> Void)
    func getDishesBy(categoryId: Int, completion: @escaping (Result<[DishDTO], Error>) -> Void)
    func getPopularDishes(completion: @escaping (Result<[FullCategoryDTO], Error>) -> Void)
    func getDishDetails(id: Int, completion: @escaping (Result<DishDTO, Error>) -> Void)
    
    func addOrder(with orderInfo: OrderDTO, completion: @escaping (Result<OrderDTO, Error>) -> Void)
}

class WebApiService: NSObject, WebApiServiceType {
    
    private static func urlSessionConfig() -> URLSessionConfiguration {
        let configuration = URLSessionConfiguration.default
        
        configuration.httpAdditionalHeaders = [:]
        configuration.httpAdditionalHeaders?["Accept"] = "application/json"
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        configuration.timeoutIntervalForRequest = 20
        
        return configuration
    }
    
    internal let encoder: JSONEncoder = JSONEncoder()
    internal let decoder: JSONDecoder = JSONDecoder()
    internal let dateFormatter: DateFormatter = DateFormatter()
    internal let afSession: Session = Session(configuration: WebApiService.urlSessionConfig())
    internal let authService: AuthServiceType
    
    init(authService as: AuthServiceType) {
        self.authService = `as`
        
    }
    
    // MARK: - Handler
    func handleResponse<T: Decodable>(of type: T.Type, response: DataResponse<T, AFError>, completion: @escaping (Result<T, Error>) -> Void) {
        switch response.result {
        case .success(let t):
            completion(.success(t))
        case .failure(let err):
            completion(.failure(self.handleError(data: response.data, error: err)))
        }
    }
    
    func handleEmptyResponse(response: DataResponse<Data?, AFError>, completion: @escaping (Result<Void, Error>) -> Void) {
        switch response.result {
        case .success:
            completion(.success(()))
        case .failure(let err):
            completion(.failure(handleError(data: response.data, error: err)))
        }
    }
    
    private func handleError(data d: Data?, error: Error) -> Error {
        print(">>>>> Error: code \((error as? AFError)?.responseCode ?? 0), message: \(error.localizedDescription)")
        if let data = d, let message = String(data: data, encoding: .utf8) {
            print(">>>>> Error message: \(message)")
            return error
        } else {
            return error
        }
    }
    
    // MARK: - Registration
    
    func registerNewUser(user: RegistrationDTO, completion: @escaping (Result<Void, Error>) -> Void) {
        afSession.request(
            CommonConstants.Registration.registerUser(),
            method: .post,
            parameters: RegistrationDTO(firstName: user.firstName, phoneNumber: user.phoneNumber),
            encoder: JSONParameterEncoder.default
        )
            .validate()
            .response { [weak self] (response) in
                self?.handleEmptyResponse(response: response, completion: completion)
            }
    }
    
    func sendConfirmation(for phoneNumber: String, confirmationCode: String, completion: @escaping (Result<JwtInfo, Error>) -> Void) {
        afSession.request(
            CommonConstants.Registration.confirmCode(),
            method: .post,
            parameters: [
                "code": confirmationCode,
                "phoneNumber": phoneNumber
            ],
            encoder: JSONParameterEncoder.default
        )
        .validate()
        .responseDecodable { [weak self] (response) in
            self?.handleResponse(of: JwtInfo.self, response: response, completion: completion)
        }
    }
    
    // MARK: - Authorization
    func authorizeUser(phoneNumber number: AuthorizationDTO, completion: @escaping (Result<Void, Error>) -> Void) {
        afSession.request(
            CommonConstants.Authorization.authorizeUser(),
            method: .post,
            parameters: AuthorizationDTO(phoneNumber: number.phoneNumber),
            encoder: JSONParameterEncoder.default
        )
            .validate()
            .response { [weak self] (response) in
                self?.handleEmptyResponse(response: response, completion: completion)
            }
    }
    
    func confirmAuthCode(for phoneNumber: String, confirmationCode: String, completion: @escaping (Result<JwtInfo, Error>) -> Void) {
        afSession.request(
            CommonConstants.Authorization.confirmAuthorizationCode(),
            method: .post,
            parameters: [
                "code": confirmationCode,
                "phoneNumber": phoneNumber
            ],
            encoder: JSONParameterEncoder.default
        )
            .validate()
            .responseDecodable { [weak self] (response) in
                self?.handleResponse(of: JwtInfo.self, response: response, completion: completion)
            }
    }
    
    // MARK: - Profile Editing
    func getUserInfo(completion: @escaping (Result<UserProfileDTO, Error>) -> Void) {
        afSession.request(
            CommonConstants.ProfileEditing.getUserInfo(),
            method: .get,
            interceptor: authService
        )
        .responseDecodable(of: UserProfileDTO.self, decoder: decoder) { [weak self] (response) in
            self?.handleResponse(of: UserProfileDTO.self, response: response, completion: completion)
        }
    }
    
    func setBirthdayToUser(userBDay: BirthdayDTO, completion: @escaping (Result<Void, Error>) -> Void) {
        afSession.request(
            CommonConstants.ProfileEditing.setBirthdayToUser(),
            method: .put,
            parameters: userBDay,
            encoder: JSONParameterEncoder.default,
            interceptor: authService
        )
        .validate()
        .response { [weak self] (response) in
            self?.handleEmptyResponse(response: response, completion: completion)
        }
    }
    
    func editProfile(name: String, birthDate: String, completion: @escaping(Result<Void, Error>) -> Void) {
        afSession.request(
            CommonConstants.ProfileEditing.editProfile(),
            method: .post,
            parameters: [
                "firstName": name,
                "bdate": birthDate
            ],
            encoder: JSONParameterEncoder.default,
            interceptor: authService
        )
        .response { [weak self] (response) in
            self?.handleEmptyResponse(response: response, completion: completion)
        }
    }
    
    // MARK: - Bonuses
    func getBonuses(completion: @escaping (Result<Int, Error>) -> Void) {
        afSession.request(
            CommonConstants.Bonus.getBonuses(),
            method: .get,
            interceptor: authService
        )
        .validate()
        .responseDecodable { [weak self] response in
            self?.handleResponse(of: Int.self, response: response, completion: completion)
        }
    }
    
    func addSubstractBonuses(amount: Int, completion: @escaping (Result<Int, Error>) -> Void) {
        afSession.request(
            CommonConstants.Bonus.addOrSubstractBonuses(amount: amount),
            method: .post,
            interceptor: authService
        )
        .validate()
        .responseDecodable { [weak self] response in
            self?.handleResponse(of: Int.self, response: response, completion: completion)
        }
    }
    
    // MARK: - Branches
    func getBranches(completion: @escaping (Result<[BranchDTO], Error>) -> Void) {
        afSession.request(
            CommonConstants.Branches.getBranches(),
            method: .get,
            interceptor: authService
        )
        .validate()
        .responseDecodable(of: [BranchDTO].self, decoder: decoder) { response in
            self.handleResponse(of: [BranchDTO].self, response: response, completion: completion)
        }
    }
    
    // MARK: - Orders
    func addOrders(order: OrderDTO, completion: @escaping (Result<Void, Error>) -> Void) {
        afSession.request(
            CommonConstants.Orders.addNewOrder(),
            method: .post,
            parameters: order,
            interceptor: authService
        )
        .validate()
        .responseDecodable { [weak self] response in
            self?.handleEmptyResponse(response: response, completion: completion)
        }
    }
    
    func checkTableAvailability(tableId: Int, completion: @escaping (Result<Bool, Error>) -> Void) {
        afSession.request(
            CommonConstants.Menu.tableAvailability(tableId: tableId),
            method: .get,
            parameters: nil,
            interceptor: authService
        )
        .validate()
        .responseDecodable { [weak self] response in
            self?.handleResponse(of: Bool.self, response: response, completion: completion)
        }
    }
    
    func getAllOrders(completion: @escaping (Result<[OrderDTO], Error>) -> Void) {
        afSession.request(
            CommonConstants.Orders.getAllOrders(),
            method: .get,
            parameters: nil,
            interceptor: authService
        )
        .validate()
        .responseDecodable { [weak self] response in
            self?.handleResponse(of: [OrderDTO].self, response: response, completion: completion)
        }
    }
    
    func getCompletedOrders(completion: @escaping (Result<[HistoryDTO], Error>) -> Void) {
        afSession.request(
            CommonConstants.Orders.getClosedOrders(),
            method: .get,
            interceptor: authService
        )
        .validate()
        .responseDecodable(of: [HistoryDTO].self, decoder: decoder) { [weak self] (response) in
            self?.handleResponse(of: [HistoryDTO].self, response: response, completion: completion)
        }
    }
    
    func getCurrentOrders(completion: @escaping (Result<[HistoryDTO], Error>) -> Void) {
        afSession.request(
            CommonConstants.Orders.getCurrentOrders(),
            method: .get,
            interceptor: authService
        )
        .validate()
        .responseDecodable(of: [HistoryDTO].self, decoder: decoder) { [weak self] (response) in
            self?.handleResponse(of: [HistoryDTO].self, response: response, completion: completion)
        }
    }
    
    func getAllCategories(completion: @escaping (Result<[CategoryDTO], Error>) -> Void) {
        afSession.request(
            CommonConstants.Orders.getAllCategories(),
            method: .get,
            parameters: nil,
            interceptor: authService
        )
        .validate()
        .responseDecodable { [weak self] response in
            self?.handleResponse(of: [CategoryDTO].self, response: response, completion: completion)
        }
    }
    
    func getCategoriesDish(categoryId: Int, completion: @escaping (Result<CategoryMenuDTO, Error>) -> Void) {
        afSession.request(
            CommonConstants.Orders.getDishesFromCategory(id: categoryId),
            method: .get,
            parameters: nil,
            interceptor: authService
        )
        .validate()
        .responseDecodable { [weak self] response in
            self?.handleResponse(of: CategoryMenuDTO.self, response: response, completion: completion)
        }
    }
    
    func getDishesBy(categoryId: Int, completion: @escaping (Result<[DishDTO], Error>) -> Void) {
        afSession.request(
            CommonConstants.Orders.getCategory(id: categoryId),
            method: .get,
            parameters: nil,
            interceptor: authService
        )
        .responseDecodable(
            of: [DishDTO].self,
            decoder: decoder
        ) { [weak self] response in
            self?.handleResponse(of: [DishDTO].self, response: response, completion: completion)
        }
    }
    
    func getPopularDishes(completion: @escaping (Result<[FullCategoryDTO], Error>) -> Void) {
        afSession.request(
            CommonConstants.Orders.getPopularDishes(),
            method: .get,
            parameters: nil,
            interceptor: authService
        )
        .validate()
        .responseDecodable { [weak self] response in
            self?.handleResponse(of: [FullCategoryDTO].self, response: response, completion: completion)
        }
    }
    
    func getDishDetails(id: Int, completion: @escaping (Result<DishDTO, Error>) -> Void) {
        afSession.request(
            CommonConstants.Orders.getDishesFromCategory(id: id),
            method: .get,
            interceptor: authService
        )
        .validate()
        .responseDecodable { [weak self] response in
            self?.handleResponse(of: DishDTO.self, response: response, completion: completion)
        }
    }
    
    func addOrder(with orderInfo: OrderDTO, completion: @escaping (Result<OrderDTO, Error>) -> Void) {
        afSession.request(
            CommonConstants.Orders.addNewOrder(),
            method: .post,
            parameters: orderInfo,
            encoder: JSONParameterEncoder.default,
            interceptor: authService
        )
        .validate()
        .responseDecodable { [weak self] response in
            self?.handleResponse(of: OrderDTO.self, response: response, completion: completion)
        }
    }
}

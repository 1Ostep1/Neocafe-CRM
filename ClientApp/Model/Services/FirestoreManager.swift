//
//  FirestoreManager.swift
//  ClientApp
//
//  Created by Ramazan Iusupov on 23/4/23.
//

import Foundation
import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift

final class FirestoreManager {
    enum FirestoreColection {
        case basket
        
        var title: String {
            switch self {
            case .basket:
                return "Basket"
            }
        }
    }
    
    public static let shared = FirestoreManager()
    
    private let db = Firestore.firestore()
    
    func saveTo<T: Codable>(collection: FirestoreColection, id: Int, data: T) {
        do {
            try db
                .collection(collection.title)
                .document(String(id))
                .setData(from: data)
            
                NotificationCenter.default.post(name: .init("com.ostep.ClientApp.saved"), object: nil)
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }
    
    func fetchData<T: Decodable>(from collection: FirestoreColection, documentId: Int) async throws -> T {
        let docRef = db.collection(collection.title).document(String(documentId))
        return try await docRef.getDocument().data(as: T.self)
    }
    
    func fetchAllData<T: Decodable>(from collection: FirestoreColection) async throws -> [T] {
        return try await db.collection(collection.title).getDocuments().documents.map { try $0.data(as: T.self) }
    }
}

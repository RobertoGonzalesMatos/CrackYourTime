//
//  SQViewModel.swift
//  TSQ
//
//  Created by Roberto Gonzales on 8/1/23.
//
import FirebaseFirestore
import FirebaseAuth
import Foundation

final class SQViewModel: ObservableObject{
    @Published var showingNewItemView = false
    
    private let userId: String
    
    init(userId: String){
        self.userId = userId
    }
    
    func delete (id: String){
        let db = Firestore.firestore()
        
        db.collection("users")
            .document(userId)
            .collection("SideQuests")
            .document(id)
            .delete()
    }
    func doneChallenges(title:String){
        guard let uId = Auth.auth().currentUser?.uid else {
            return
        }
        
        let newId = UUID().uuidString
        
        let db = Firestore.firestore()
        
        db.collection("users")
            .document(uId)
            .collection("doneChallenges")
            .document(newId)
            .setData(["title":title,"id":newId])
    }
}

//
//  TaskViewModel.swift
//  TSQ
//
//  Created by Roberto Gonzales on 7/30/23.
//

import FirebaseFirestore
import Foundation

class TaskViewModel: ObservableObject{
    @Published var showingNewItemView = false
    
    private let userId: String
    
    init(userId: String){
        self.userId = userId
    }
    
    func delete (id: String){
        let db = Firestore.firestore()
        
        db.collection("users")
            .document(userId)
            .collection("tasks")
            .document(id)
            .delete()
    }
    

}

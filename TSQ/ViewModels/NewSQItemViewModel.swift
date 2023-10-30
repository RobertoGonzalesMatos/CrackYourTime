//
//  NewSQItemViewModel.swift
//  TSQ
//
//  Created by Roberto Gonzales on 8/7/23.
//

//
//  NewItemViewModel.swift
//  TSQ
//
//  Created by Roberto Gonzales on 7/30/23.
//

import FirebaseAuth
import FirebaseFirestore
import Foundation

class NewSQViewModel: ObservableObject{
    
    @Published var title = ""
    @Published var showAlert = false
    
    init(){}
    
    func save(){
        guard canSave else{
            return
        }
        
        guard let uId = Auth.auth().currentUser?.uid else {
            return
        }
        
        let newId = UUID().uuidString
        
        let newItem = SQItem(id: newId,
                                title: title,
                                createDate: Date().timeIntervalSince1970)
        
        let db = Firestore.firestore()
        
        db.collection("users")
            .document(uId)
            .collection("SideQuests")
            .document(newId)
            .setData(newItem.asDictionary())
        
    }
    
    var canSave: Bool {
        guard !title.trimmingCharacters(in: .whitespaces).isEmpty else{
            return false
        }
        
        return true
    }

}

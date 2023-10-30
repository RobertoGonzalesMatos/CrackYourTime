//
//  ShareViewModel.swift
//  TSQ
//
//  Created by Roberto Gonzales on 8/10/23.
//

import Foundation
import FirebaseFirestore

class ShareViewModel: ObservableObject{
    @Published var alert: Bool = false
    @Published var item: TasksItem?
    
    func setUp(item: TasksItem){
        self.item = item
    }
    
    func share (shareName: String){
        guard shareName != "" else{
            alert = true
            return}
        
        let db = Firestore.firestore()
        
        let usersCollection = db.collection("users")
        
        // Create a query to find the user by username
        let query = usersCollection.whereField("name", isEqualTo: shareName)
        
        query.getDocuments{ (querySnapshot, error) in
            let document = querySnapshot?.documents.first
            let id = document?.documentID
            guard id != "" && id != nil else{
                self.alert = true
                return}
            
            db.collection("users")
                .document(id ?? "")
                .collection("tasks")
                .document(self.item?.id ?? "")
                .setData((self.item?.asDictionary())!)
        }
    }
}

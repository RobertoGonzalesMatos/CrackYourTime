//
//  TaskItemViewModel.swift
//  TSQ
//
//  Created by Roberto Gonzales on 7/30/23.
//

import FirebaseAuth
import FirebaseFirestore
import Foundation

class TaskItemViewModel: ObservableObject{
    init(){}
    
    func toggleIsDone(item: TasksItem){
        var itemCopy = item
        itemCopy.setDone(!item.isDone)
//        print(itemCopy.isDone)
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        let db = Firestore.firestore()
        
        db.collection("users")
            .document(uid)
            .collection("tasks")
            .document(itemCopy.id)
            .setData(itemCopy.asDictionary())
    }
}

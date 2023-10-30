//
//  NewItemViewModel.swift
//  TSQ
//
//  Created by Roberto Gonzales on 7/30/23.
//

import FirebaseAuth
import FirebaseFirestore
import Foundation
import UserNotifications

class NewItemViewModel: ObservableObject{
    
    @Published var title = ""
    @Published var dueDate = Date()
    @Published var showAlert = false
    
    init(){
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
//                print("All set!")
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    func save(){
        guard canSave else{
            return
        }
        
        guard let uId = Auth.auth().currentUser?.uid else {
            return
        }
        
        let newId = UUID().uuidString
        
        let newItem = TasksItem(id: newId,
                                title: title,
                                dueDate: dueDate.timeIntervalSince1970,
                                createDate: Date().timeIntervalSince1970,
                                isDone: false)
        
        let db = Firestore.firestore()
        
        db.collection("users")
            .document(uId)
            .collection("tasks")
            .document(newId)
            .setData(newItem.asDictionary())
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.subtitle = "Looks like your time for a task has come!"
        content.sound = UNNotificationSound.default
        var timeUntilNotification = dueDate.timeIntervalSince1970 - Date().timeIntervalSince1970
        
        if (timeUntilNotification) < 0 {
            timeUntilNotification = 5
        }
        
        // show this notification five seconds from now
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeUntilNotification, repeats: false)

        // choose a random identifier
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        // add our notification request
        UNUserNotificationCenter.current().add(request)

    }
    
    var canSave: Bool {
        guard !title.trimmingCharacters(in: .whitespaces).isEmpty else{
            return false
        }
        
        guard dueDate >= Date().addingTimeInterval(-86400) else {
            return false
        }
        
        return true
    }

}

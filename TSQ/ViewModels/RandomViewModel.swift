//
//  RandomViewModel.swift
//  TSQ
//
//  Created by Roberto Gonzales on 8/5/23.
//

import Foundation
import Firebase

class RandomViewModel: ObservableObject {
    @Published var list = [TasksItem]()
    var titleList: [String] = []
    var toggle: Bool = true
    var titleListShort: [String] = []
    
    func getData(userId: String){
        let db = Firestore.firestore()
        
        db.collection("users/\(userId)/\(change())").getDocuments { snapshot, error in
            if error == nil {
                if let snapshot = snapshot {
                    DispatchQueue.main.async {
                        self.list = snapshot.documents.map { d in
                            return TasksItem(id: d.documentID,
                                             title: d["title"] as? String ?? "",
                                             dueDate: d["dueDate"] as? TimeInterval ?? 0,
                                             createDate: d["createDate"] as? TimeInterval ?? 0,
                                             isDone: d["isDone"] as? Bool ?? false)
                        }
                        if self.toggle{
                            let presentTasks = self.list.filter { task in
                                Date(timeIntervalSince1970: 0).addingTimeInterval(task.dueDate) >= Date.init()
                            }
                            self.titleList = presentTasks.map {$0.title}
                            self.titleListShort = self.titleList.map{String($0.prefix(15))}
                        } else {
                            self.titleList = self.list.map {$0.title}
                            self.titleListShort = self.titleList.map{String($0.prefix(7)+"...")}
                        }
//                        print("\(self.titleList.count)")
                    }
                }
//                print("\(self.titleList.count)")
            }
                
        }
    }
    
    func checkData(userId: String, type: String) -> [String]{
        let db = Firestore.firestore()
        var lista = [String]()
        db.collection("users/\(userId)/\(change())").getDocuments { snapshot, error in
            if error == nil {
                if let snapshot = snapshot {
                    DispatchQueue.main.async {
                        lista = snapshot.documents.map { d in
                            return d.documentID
                        }
                    }
                }
            }
                
        }
        return lista
    }
    
    func change() -> String{
        if toggle {
            return "tasks"
        }
        return "SideQuests"
    }
    func check(a: String) -> Bool {
        return checkData(userId: a, type: "tasks") == checkData(userId: a, type: "SideQuests")
    }
}

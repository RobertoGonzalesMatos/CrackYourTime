//
//  NewItemViewModel.swift
//  TSQ
//
//  Created by Roberto Gonzales on 7/30/23.
//


import FirebaseStorage
import FirebaseFirestore
import Foundation
import UIKit

class DrawViewModel: ObservableObject{
//    init(){}
    
    func save(image: UIImage, uId: String){
        let storageRef = Storage.storage().reference()
        
        let Image = image.jpegData(compressionQuality: 0.8)
        
        guard Image != nil else{
            print("a")
            return
        }
        
        let newId = UUID().uuidString
        
        let path = "images/\(newId).jpg"
        
        let fileRef = storageRef.child(path)
        print("d")
        _ = fileRef.putData(Image!, metadata: nil) { metadata, error in
            let db = Firestore.firestore()
            db.collection("users")
                .document(uId)
                .collection("Images")
                .document(newId)
                .setData(["url": path])
        }
    }
}


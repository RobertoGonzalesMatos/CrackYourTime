//
//  User.swift
//  TSQ
//
//  Created by Roberto Gonzales on 7/30/23.
//

import Foundation

struct User: Codable{
    let id: String
    let name: String
    let email: String
    let joined: TimeInterval
}

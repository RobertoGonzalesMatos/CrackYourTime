//
//  TaskTitle.swift
//  TSQ
//
//  Created by Roberto Gonzales on 8/5/23.
//

import Foundation

struct TasksItem: Codable, Identifiable {
    let id: String
    let title: String
    let dueDate: TimeInterval
    let createDate: TimeInterval
    var isDone: Bool
    
    mutating func setDone(_ state: Bool){
        isDone = state
    }
}

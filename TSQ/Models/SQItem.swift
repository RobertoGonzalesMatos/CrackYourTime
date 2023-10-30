//
//  SQItem.swift
//  TSQ
//
//  Created by Roberto Gonzales on 8/7/23.
//

import Foundation

struct SQItem: Codable, Identifiable {
    let id: String
    let title: String
    let createDate: TimeInterval
}

//
//  Extensions.swift
//  TSQ
//
//  Created by Roberto Gonzales on 7/31/23.
//

import Foundation
import SwiftUI

extension Encodable {
    func asDictionary() -> [String: Any]{
        guard let data = try? JSONEncoder().encode(self) else{
            return [:]
        }
        
        do{
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            return json ?? [:]
        }  catch {
            return [:]
        }
    }
}

extension Array where Element == Line {
    func toCoordinates() -> [String: [[Int]]] {
        var result: [String: [[Int]]] = [:]

        for line in self {
            var lineCoordinates: [[Int]] = []

            for point in line.points {
                let pointCoordinates = [Int(point.x),Int(point.y)]
                lineCoordinates.append(pointCoordinates)
            }

            result[line.color.description] = lineCoordinates
        }
//        print(result)
        return result
    }
}


extension Encodable {
    func intToCGPoint() -> [Int]{
        let a:CGPoint = self as! CGPoint
        return [Int(a.x),Int(a.y)]
    }
}

extension View {
    func snapshot() -> UIImage {
        let controller = UIHostingController(rootView: self)
        let view = controller.view
        
        let targetSize = controller.view.intrinsicContentSize
        view?.bounds = CGRect(origin: .zero, size: targetSize)
        view?.backgroundColor = .clear
        
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        
        return renderer.image { _ in
            view?.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
    }
}

extension View {
    @ViewBuilder
    func hSpacing(_ alignment: Alignment) -> some View {
        self.frame(maxWidth: .infinity,alignment: alignment)
    }
    
    @ViewBuilder
    func vSpacing(_ alignment: Alignment) -> some View {
        self.frame(maxHeight: .infinity,alignment: alignment)
    }
    
    func isSameDate(_ date1:Date, _ date2:Date) -> Bool {
        return Calendar.current.isDate(date1, inSameDayAs: date2)
    }
}

extension Date {
    func format(_ format: String) -> String{
        let formatter = DateFormatter()
        formatter.dateFormat = format
        
        return formatter.string(from: self)
    }
    
    var isToday: Bool {return Calendar.current.isDateInToday(self)}
    
    func fetchWeek(_ date: Date = .init()) -> [WeekDay] {
        let calendar = Calendar.current
        let startOfDate = calendar.startOfDay(for: date)
        
        var week: [WeekDay] = []
        let weekForDate = calendar.dateInterval(of: .weekOfMonth, for: startOfDate)
        
        guard let startOfWeek = weekForDate?.start else {
            return []
        }
        
        (0..<7).forEach { index in
            if let weekDay = calendar.date(byAdding: .day, value: index, to: startOfWeek) {
                week.append(.init(date: weekDay))
            }
        }
        
        return week
    }
    
    func createNextWeek() -> [WeekDay] {
        let calendar = Calendar.current
        let startOfLastDate = calendar.startOfDay(for: self)
        guard let nextDate = calendar.date(byAdding: .day, value: 1, to: startOfLastDate) else {
            return []
        }
        return fetchWeek(nextDate)
    }
    
    func createPrevWeek() -> [WeekDay] {
        let calendar = Calendar.current
        let startOfFirstDate = calendar.startOfDay(for: self)
        guard let prevDate = calendar.date(byAdding: .day, value: -1, to: startOfFirstDate) else {
            return []
        }
        return fetchWeek(prevDate)
    }
    
    struct WeekDay: Identifiable {
        var id: UUID = .init()
        var date: Date
    }
    
    func isWithin(date:Date) -> Bool{
        let calendar = Calendar.current
        
        let components1 = calendar.dateComponents([.year, .month, .day], from: self)
        let components2 = calendar.dateComponents([.year, .month, .day], from: date)
        
        return components1.year == components2.year && components1.month == components2.month && components1.day == components2.day
    }
}



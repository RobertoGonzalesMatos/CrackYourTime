//
//  test.swift
//  TSQ
//
//  Created by Roberto Gonzales on 8/7/23.
//

import Foundation

let inputString = "1. Visit a National Monument or Park and take a free guided tour\n2. Try a water sport like surfing or kayaking\n3. Spend the night camping under the stars\n4. Take a spontaneous road trip to a nearby town and explore the local shops/eateries\n5. Stop and take pictures of 5 interesting landmarks you have never heard of before."

let pattern = #"^\d+\.\s+"#
let regex = try! NSRegularExpression(pattern: pattern, options: [])

let range = NSRange(inputString.startIndex..<inputString.endIndex, in: inputString)
let matches = regex.matches(in: inputString, options: [], range: range)

var ideaStrings = [String]()

for match in matches {
    let start = match.range.upperBound
    let end = match.range.upperBound == inputString.endIndex ? inputString.endIndex : inputString.index(after: match.range.upperBound)
    let idea = inputString[start..<end].trimmingCharacters(in: .whitespacesAndNewlines)
    ideaStrings.append(idea)
}

for idea in ideaStrings {
    print(idea)
}

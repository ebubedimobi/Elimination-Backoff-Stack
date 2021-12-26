//
//  EliminationArray.swift
//  Elimination Backoff Stack
//
//  Created by Ebubechukwu Dimobi on 26.12.2021.
//

import Foundation

// Elimination array provides a list of exchangers which
// are picked at random for a given value.

class EliminationArray<T: Equatable> {
    var exchangers: [Exchanger<T>]  // array of exchangers
    let timeout: Double          //exchange timeout number
    let timeUnit: TimeUnit      //exchange timeout unit
    
    init(capacity: Int, timeout: Double, timeUnit: TimeUnit) {
        exchangers = [Exchanger<T>]()
        exchangers.reserveCapacity(capacity)
        for _ in 0..<capacity {
            exchangers.append(Exchanger())
        }
        self.timeout = timeout
        self.timeUnit = timeUnit
    }
    
    // Try exchanging value on a random exchanger.
    func visit(with value: T) throws -> T? {
        let randomIndex = Int.random(in: 0..<exchangers.count)
        return try exchangers[randomIndex].exchange(value: value, timeout: timeout, unit: timeUnit)
    }
}

//
//  Double+Extension.swift
//  Elimination Backoff Stack
//
//  Created by Ebubechukwu Dimobi on 26.12.2021.
//

import Foundation

//Extension for changing type Double from seconds to nanoSeconds
extension Double {
    
    func toNano() -> Double {
        return TimeUnit.seconds.change(to: .nanoSeconds, value: self)
    }
}

//Custom time unit and unit change
enum TimeUnit: Double {
    case seconds = 1
    case milliseconds = 1000
    case nanoSeconds = 1000000000
    
    func change(to: TimeUnit, value: Double) -> Double {
        return (to.rawValue * value) / self.rawValue
    }
}

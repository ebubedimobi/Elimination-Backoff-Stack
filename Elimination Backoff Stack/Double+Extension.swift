//
//  Double+Extension.swift
//  Elimination Backoff Stack
//
//  Created by Ebubechukwu Dimobi on 26.12.2021.
//

import Foundation

extension Double {
    
    func toNano() -> Double {
        return TimeUnit.seconds.change(to: .nanoSeconds, value: self)
    }
}


enum TimeUnit: Double {
    case seconds = 1
    case nanoSeconds = 1000000000
    
    func change(to: TimeUnit, value: Double) -> Double {
        return (to.rawValue * value) / self.rawValue
    }
}

//
//  Exchanger.swift
//  Elimination Backoff Stack
//
//  Created by Ebubechukwu Dimobi on 26.12.2021.
//

import Foundation
import CoreLocation

private enum States: Int {
    case empty = 0
    case waiting = 1
    case busy = 2
}

class Exchanger<T: Equatable> {
    var slot: AtomicStampedReference<T> // slot: stores value and stamp
    
    init() {
        slot = AtomicStampedReference<T>(value: nil, stamp: States.empty.rawValue)
    }
    
    // 1. Calculate last wait time.
    // 2. If wait time exceeded, then throw expection.
    // 3. Get slot value and stamp.
    // 4a. If slot is EMPTY (no value):
    // 4b. Try adding 1st value to slot, else retry 2.
    // 4c. Try getting 2nd value from slot, within time limit.
    // 5a. If slot is WAITING (has 1st value):
    // 5b. Try adding 2nd value to slot, else retry 2.
    // 5c. Return 1st value.
    // 6a. If slot is BUSY (has 2nd value):
    // 6b. Retry 2.
    func exchange(value: T?, timeout: Double, unit: TimeUnit) throws -> T? {
        let waitTime = CFAbsoluteTimeGetCurrent().toNano() + unit.change(to: .nanoSeconds, value: timeout) //1
        
        while CFAbsoluteTimeGetCurrent().toNano() < waitTime { //2
            let holder = slot.getStampHolder()                 //3
            switch States(rawValue: holder.stamp) {            //3
            case .empty:                                       //4a
                if addA(value) {                               //4b
                    while CFAbsoluteTimeGetCurrent().toNano() < waitTime { //4c
                        let b = removeB()                                  //4c
                        if b != nil { return b }                           //4c
                    }
                    throw ErrorType.timeOutException                       //4c
                }
                break
            case .waiting:                                                 //5a
                if addB(a: holder.value, b: value) { return holder.value } //5b, 5c
            case .busy:                                                    //6a
                break                                                      //6a
            default:
                break                                                      //6a
            }
        }
        
        throw ErrorType.timeOutException //2
    }
    
    // Add 1st value to slot.
    // Set its stamp as WAITING (for 2nd).
    private func addA(_ a: T?) -> Bool {
        return slot.compareAndSet(
            expectedValue: nil,
            newValue: a,
            expectedStamp: States.empty.rawValue,
            newStamp: States.waiting.rawValue
        )
    }
    
    // 1. Add 2nd value to slot.
    // 2. Set its stamp as BUSY (for 1st to remove).
    private func addB(a: T?, b: T?) -> Bool {
        return slot.compareAndSet(
            expectedValue: a,
            newValue: b,
            expectedStamp: States.waiting.rawValue,
            newStamp: States.busy.rawValue
        )
    }
    
    // 1. If stamp is not BUSY (no 2nd value in slot), exit.
    // 2. Set slot as EMPTY, and get 2nd value from slot.
    private func removeB() -> T? {
        let holder = slot.getStampHolder()                      //1
        if holder.stamp != States.busy.rawValue { return nil }  //1
        slot.set(newValue: nil, newStamp: States.empty.rawValue)
        return holder.value
    }
}

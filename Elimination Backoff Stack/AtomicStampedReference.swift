//
//  AtomicStampedReference.swift
//  Elimination Backoff Stack
//
//  Created by Ebubechukwu Dimobi on 26.12.2021.
//

import Foundation

// Since swift doesn't support atomicStampedReference from the box
// i have to create my own implementation

struct AtomicStampedReference<Value: Equatable> {

    private var value: Value?
    private var stamp: Int
    private let lock = NSRecursiveLock()

    init(value: Value?, stamp: Int) {
        self.value = value
        self.stamp = stamp
    }
    
    /// Returns the current value of the reference
    /// - Returns: the current value of the reference
    func getReference() -> Value? {
        lock.lock()
        defer { lock.unlock() }
        return value
    }
    
    /// Returns the current value of the stamp
    /// - Returns: the current value of the stamp
    func getStamp() -> Int {
        lock.lock()
        defer { lock.unlock() }
        return stamp
    }
    
    /// Returns the current values of both the reference and the stamp
    /// - Returns: current values of both the reference and the stamp
    func getStampHolder() -> (stamp: Int, value: Value?) {
        lock.lock()
        defer { lock.unlock() }
        return (stamp, value)
    }
    
    /// Unconditionally sets the value of both the reference and stamp
    /// - Parameters:
    ///   - newValue: the new value for the reference
    ///   - newStamp: the new value for the stamp
    mutating func set(newValue: Value, newStamp: Int) {
        lock.lock()
        defer { lock.unlock() }
        value = newValue
        stamp = newStamp
    }
    
    /// Atomically sets the value of both the reference and stamp to the given update values if the current reference is == to the expected reference and the current stamp is equal to the expected stamp
    /// - Parameters:
    ///   - expectedValue: the expected value of the reference
    ///   - newValue: the new value for the reference
    ///   - expectedStamp: the expected value of the stamp
    ///   - newStamp: the new value for the stamp
    /// - Returns: true if successful
    mutating func compareAndSet(
        expectedValue: Value,
        newValue: Value?,
        expectedStamp: Int,
        newStamp: Int
    ) -> Bool {
        lock.lock()
        defer { lock.unlock() }
        let isSame = (value == expectedValue && stamp == expectedStamp)
        if isSame {
            value = newValue
            stamp = newStamp
        }
        return isSame
    }
    
    /// Atomically sets the value of the stamp to the given update value if the current reference is == to the expected reference. Any given invocation of this operation may fail (return false) spuriously, but repeated invocation when the current value holds the expected value and no other thread is also attempting to set the value will eventually succeed.
    /// - Parameters:
    ///   - expectedValue: the expected value of the reference
    ///   - newStamp:  the new value for the stamp
    /// - Returns: true if successful
    mutating func attemptStamp(
        expectedValue: Value,
        newStamp: Int
    ) -> Bool {
        lock.lock()
        defer { lock.unlock() }
        let isSame = value == expectedValue
        if isSame {
            stamp = newStamp
        }
        return isSame
    }
}

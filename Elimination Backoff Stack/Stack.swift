//
//  Stack.swift
//  Elimination Backoff Stack
//
//  Created by Ebubechukwu Dimobi on 26.12.2021.
//

import Foundation

class Stack<T: Equatable> {
    private var items: [T] = []
    
    func peek() -> T {
        guard let topElement = items.first else { fatalError("This stack is empty.") }
        return topElement
    }
    
    func pop() -> T {
        return items.removeFirst()
    }
  
    func push(_ element: T) {
        items.insert(element, at: 0)
    }
}

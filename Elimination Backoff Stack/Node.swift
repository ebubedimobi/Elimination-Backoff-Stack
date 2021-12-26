//
//  Node.swift
//  Elimination Backoff Stack
//
//  Created by Ebubechukwu Dimobi on 26.12.2021.
//

import Foundation

class Node<T: Equatable> {
    var value: T
    var next: Node<T>?
    
    init(value: T) {
        self.value = value
    }
    
//    deinit {
//
//    }
}

extension Node: Equatable {
    static func == (lhs: Node<T>, rhs: Node<T>) -> Bool {
        return lhs.value == rhs.value
    }
}

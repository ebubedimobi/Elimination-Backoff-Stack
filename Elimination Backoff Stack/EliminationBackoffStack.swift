//
//  EliminationBackoffStack.swift
//  Elimination Backoff Stack
//
//  Created by Ebubechukwu Dimobi on 26.12.2021.
//

import Foundation

// Elimination-backoff stack is an unbounded lock-free LIFO
// linked list, that eliminates concurrent pairs of pushes
// and pops with exchanges.  It uses compare-and-set (CAS)
// atomic operation to provide concurrent access with
// obstruction freedom. In order to support even greater
// concurrency, in case a push/pop fails, it tries to
// pair it with another pop/push to eliminate the operation
// through exchange of values.

class EliminationBackOffStack<T: Equatable> {
    var top: Atomic<Node<T>> //top of stack (null if empty)
    let eliminatiionArray: EliminationArray<T> //for exchanging values between push, pop
    final let capacity = 100  //capacity of elimination array
    final let timeout: Double = 10    //exchange timeout for elimination array
    final let unit: TimeUnit = .milliseconds  //exchange timeout unit for elimination array
    
    init() {
        self.top = Atomic(value: nil)
        self.eliminatiionArray = EliminationArray(
            capacity: capacity,
            timeout: timeout,
            timeUnit: unit
        )
    }
    
     // 1. Create a new node with given value.
     // 2. Try pushing it to stack.
     // 3a. If successful, return.
     // 3b. Otherwise, try exchanging on elimination array.
     // 4a. If found a matching pop, return.
     // 4b. Otherwise, retry 2.
    func push(_ value: T) {
        let newNode = Node(value: value)   //1
        while true {
            if tryPush(newNode: newNode) { return }    //2, 3a
            do {
                let otherValue = try eliminatiionArray.visit(with: value)  //3b
                if otherValue == nil { return }                            //4a
            } catch {}
        } // 4b
    }
    
      // 1. Try popping a node from stack.
      // 2a. If successful, return node's value
      // 2b. Otherwise, try exchanging on elimination array.
      // 3a. If found a matching push, return its value.
      // 3b. Otherwise, retry 1.
    func pop() throws -> T? {
        while true {
            let poppedNode = try tryPop()     //1
            if poppedNode != nil { return poppedNode?.value }  //2a
            do {
                let otherValue = try eliminatiionArray.visit(with: nil)   //2b
                if otherValue != nil { return otherValue }               //3a
            } catch { }
        }  //                                                            //3b
    }
    
     // 1. Get stack top.
     // 2. Set node's next to top.
     // 3. Try push node at top (CAS).
    func tryPush(newNode: Node<T>) -> Bool {
        let currentTopNode = top.get()  //1
        newNode.next = currentTopNode   //2
        return top.compareAndSet(valueToCompare: currentTopNode, newValue: newNode) //3
    }
    
    // 1. Get stack top, and ensure stack not empty.
    // 2. Try pop node at top, and set top to next (CAS).
    func tryPop() throws -> Node<T>? {
        let currentTopNode = top.get()         //1
        if currentTopNode == nil {             //1
            throw ErrorType.emptyStackException
        }
        let newTopNode = currentTopNode?.next   //2
        return top.compareAndSet(valueToCompare: currentTopNode, newValue: newTopNode) //2
        ? currentTopNode
        : nil
    }
}

//
//  main.swift
//  Elimination Backoff Stack
//
//  Created by Ebubechukwu Dimobi on 26.12.2021.
//

import Foundation



var NUM = 1000 // CS: critical section executed per thread
var TH = 10  // TH: number of threads
var useConcurrentStack = true // test with our safe concurrent stack or not

class Main {
    let stack: Stack<Int>
    let concurrentStack: EliminationBackOffStack<Int>
    var poppedValues: [Int: [Int?]] = [:]
    var threads: [Thread] = []
    let benchMarker: BenchMarkable & Loggable = BenchMark(threadCount: TH)
    
    init() {
        self.stack = .init()
        self.concurrentStack = .init()
    }
    
    // Each unsafe thread pushes N numbers and pops N, adding
    // them to its own poppedValues for checking; using Java's
    // sequential stack implementation, ArrayDeque.
    func createThreadUsingUnSafeStack(threadNumber: Int, value: Int, capacity: Int) -> Thread {
        let threadNumber = threadNumber
        
        let thread = Thread {
            var value = value
            for _ in 0..<capacity {
                self.stack.push(value)
                value += 1
            }
            Thread.sleep(forTimeInterval: 3.0)
            var localStorage = [Int?]()
            for _ in 0..<capacity {
                localStorage.append( self.stack.pop())
                self.poppedValues[threadNumber] = localStorage
            }
        }
        thread.start()
        return thread
    }
    
    // Each safe thread pushes N numbers and pops N, adding
    // them to its own poppedValues for checking; using
    // BackoffStack.
    func createThreadUsingSafeStack(threadNumber: Int, value: Int, capacity: Int) -> Thread {
        let threadNumber = threadNumber
        
        let thread = Thread {
            var action = "push"
            do {
                var value = value
                for _ in 0..<capacity {
                    self.concurrentStack.push(value)
                    value += 1
                }
                
//                Thread.sleep(forTimeInterval: 6.0)
                action = "pop"
                for _ in 0..<capacity {
                    let poppedValue = try self.concurrentStack.pop()
                    self.poppedValues[threadNumber]?.append(poppedValue)
                }
                self.benchMarker.logTime()
                let array = self.poppedValues[threadNumber]!.compactMap({ $0 })
                print(
                    "\n",
                    "thread \(threadNumber)\n","count - ",
                    array.count,
                    "\n",
                    array,
                    "\n"
                )
            } catch {
                print("thread\(threadNumber): failed \(action)")
            }
        }
        thread.start()
        return thread
    }
    
    func testThreads(useBackOffStack: Bool) {
        for threadNumber in 0..<TH {
            poppedValues[threadNumber] = []
        }
        var threads: [Thread] = []
        threads.reserveCapacity(TH)
        benchMarker.startTimer()
        for counter in 0..<TH {
            threads.append(
                useBackOffStack
                ? createThreadUsingSafeStack(threadNumber: counter, value: counter * NUM, capacity: NUM)
                : createThreadUsingUnSafeStack(threadNumber: counter, value: counter * NUM, capacity: NUM)
            )
        }
        
    }
    
}

func startup() {
    print("Enter number of threads")
    if let parameters = readLine() {
        TH = Int(parameters) ?? TH
    }
    
    let main = Main()
    main.testThreads(useBackOffStack: true)
}

startup()


RunLoop.main.run()


//
//  BenchMark.swift
//  MCSLock
//
//  Created by Ebubechukwu Dimobi on 20.12.2021.
//

import Foundation

protocol BenchMarkable {
    func startTimer()
    func increaseRelapsedTime()
}

protocol Loggable {
    func logTime()
    func createCSV(name: String)
}


class BenchMark {
    private var startTime: CFAbsoluteTime
    private var database:[Dictionary<String, AnyObject>] = Array()
    var elapsedTime: Double = .zero
    let threadCount: Int
    var counter: Atomic<Int> = .init(value: 0)
    
    init(threadCount: Int) {
        self.threadCount = threadCount
        startTime = CFAbsoluteTimeGetCurrent()
    }
}

extension BenchMark: Loggable {
    func logTime() {
        self.increaseRelapsedTime()
        let count = counter.increaseAndGet()
        guard count >= threadCount else {
            return
        }
        var dct = Dictionary<String, AnyObject>()
        dct.updateValue(threadCount as AnyObject, forKey: "Thread")
        dct.updateValue(self.elapsedTime - 3000 as AnyObject, forKey: "Time")
        database.append(dct)
        createCSV(name: "\(threadCount)threads")
    }
    
    func createCSV(name: String) {
        var csvString = "\("Number of Threads"),\("Time (ms)")\n\n"
        for dct in database {
            csvString = csvString.appending("\(String(describing: dct["Thread"]!)) ,\(String(describing: dct["Time"]!))\n")
        }
        
        let fileManager = FileManager.default
        do {
            let path = try fileManager.url(for: .downloadsDirectory, in: .allDomainsMask, appropriateFor: nil, create: false)
            let fileURL = path.appendingPathComponent("\(name).csv")
            try csvString.write(to: fileURL, atomically: true, encoding: .utf8)
        } catch {
            print("error creating file")
        }
        
    }
}

extension BenchMark: BenchMarkable {
    func increaseRelapsedTime() {
        elapsedTime = (CFAbsoluteTimeGetCurrent() - startTime) * 1000
    }
    
    func startTimer() {
        counter.set(0)
        startTime = CFAbsoluteTimeGetCurrent()
    }
}

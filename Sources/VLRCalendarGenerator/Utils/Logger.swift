//
//  Logger.swift
//  VLRCalendarGenerator
//
//  Created by Chinh Ngo on 03.02.26.
//

import Foundation

protocol Logging {
    func info(_ message: @autoclosure () -> String)
    func debug(_ message: @autoclosure () -> String)
    func error(_ message: @autoclosure () -> String)
}

struct Logger: Logging {
    let isVerbose: Bool

    func info(_ message: @autoclosure () -> String) {
        print("✅ " + message())
    }

    func debug(_ message: @autoclosure () -> String) {
        guard isVerbose else { return }
        print("[DEBUG] " + message())
    }
    
    func error(_ message: @autoclosure () -> String) {
        if let data = ("❌ " + message() + "\n").data(using: .utf8) {
            try? FileHandle.standardError.write(contentsOf: data)
        }
    }
}

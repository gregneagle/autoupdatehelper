//
//  logging.swift
//  autoupdatehelper
//
//  Created by Greg Neagle on 11/12/26.
//

import Foundation
import OSLog

/// A singleton object so we can keep a single reference to a Logger
class InternalLogger {
    static let shared = InternalLogger()

    let logger: Logger

    private init() {
        let subsystem = Info.identifier
        logger = Logger(subsystem: subsystem, category: "")
    }

    func log(_ message: String, logLevel: OSLogType = .default) {
        logger.log(level: logLevel, "\(message, privacy: .public)")
    }
}


/// General logging function
func log(_ message: String, logLevel: OSLogType = .default) {
    InternalLogger.shared.log(message, logLevel: logLevel)
}

func printAndLog(_ message: String) {
    print(message)
    log(message)
}


//
//  logging.swift
//  autoupdatehelper
//
//  Created by Greg Neagle on 11/12/26.
//

import Foundation
import OSLog

/// General logging function
func log(_ message: String, logLevel: OSLogType = .default) {
    let subsystem = Info.identifier
    let logger = Logger(subsystem: subsystem, category: "")
    logger.log(level: logLevel, "\(message, privacy: .public)")
}

func printAndLog(_ message: String) {
    print(message)
    log(message)
}


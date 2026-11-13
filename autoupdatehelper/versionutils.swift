//
//  versionutils.swift
//  autoupdatehelper
//
//  Created by Greg Neagle on 11/11/26.
//

import Foundation

/// Struct to compare two version strings in a consistent way
struct ProductVersion: Equatable, Comparable {
    let value: String

    init(_ str: String) {
        value = str
    }

    /// pads version strings by adding extra ".0"s to one if needed
    static func pad(_ a: String, count: Int) -> String {
        var components = a.split(separator: ".", omittingEmptySubsequences: true)
        while components.count < count {
            components.append("0")
        }
        return components.joined(separator: ".")
    }

    /// number of dot-separated components in a version string
    private static func componentCount(_ version: String) -> Int {
        return version.split(separator: ".", omittingEmptySubsequences: true).count
    }

    /// compares two version strings and returns a ComparisonResult
    static func compare(_ lhs: String, _ rhs: String) -> ComparisonResult {
        let maxCount = max(componentCount(lhs), componentCount(rhs))
        let a = pad(lhs, count: maxCount)
        let b = pad(rhs, count: maxCount)
        return a.compare(b, options: .numeric)
    }

    static func < (lhs: ProductVersion, rhs: ProductVersion) -> Bool {
        return compare(lhs.value, rhs.value) == .orderedAscending
    }

    static func > (lhs: ProductVersion, rhs: ProductVersion) -> Bool {
        return compare(lhs.value, rhs.value) == .orderedDescending
    }

    static func == (lhs: ProductVersion, rhs: ProductVersion) -> Bool {
        return compare(lhs.value, rhs.value) == .orderedSame
    }
}

//
//  prefs.swift
//  autoupdatehelper
//
//  Created by Greg Neagle on 11/10/26.
//

import Foundation

/// Convenience for working with preferences in /Library/Preferences/com.apple.SoftwareUpdate.plist
struct SUSharedPrefs {
    static let IDENTIFIER = "com.apple.SoftwareUpdate" as CFString
    static let prefsFilePath = "/Library/Preferences/com.apple.SoftwareUpdate.plist"

    static func sync() {
        CFPreferencesAppSynchronize(IDENTIFIER)
    }

    /// Gets a preferences value from /Library/Preferences/com.apple.SoftwareUpdate.plist
    static func get(_ prefName: String) -> Any? {
        return CFPreferencesCopyValue(
            prefName as CFString,
            IDENTIFIER,
            kCFPreferencesAnyUser,
            kCFPreferencesCurrentHost
        )
    }

    /// Writes a preferences value to /Library/Preferences/com.apple.SoftwareUpdate.plist
    /// (requires root)
    static func set(_ prefName: String, _ prefValue: Any?) {
        if let key = prefName as CFString? {
            if let value = prefValue as CFPropertyList? {
                CFPreferencesSetValue(
                    key as CFString, value, IDENTIFIER,
                    kCFPreferencesAnyUser, kCFPreferencesCurrentHost
                )
                sync()
            }
        }
    }

    /// Reads directly from the prefs file without using CFPreferences functions
    static func getValueForKeyFromPrefsFile(_ key: String) -> Any? {
        if let plistDict = NSDictionary(contentsOfFile: prefsFilePath) as? [String: Any] {
            return plistDict[key]
        }
        return nil
    }
}

/// Struct for working with this tool's preferences
struct Preferences {
    // gets a preference from our preferences domain,
    // honoring the various preference "levels" including MCX/config profiles
    private static func get(_ prefName: String) -> Any? {
        return CFPreferencesCopyAppValue(
            prefName as CFString,
            Info.identifier as CFString
        )
    }

    // specific supported preferences
    static var allowMajor: Bool {
        return get("allowMajor") as? Bool ?? false
    }
    static var updateDelayDays: Int {
        let value = get("updateDelayDays") as? Int ?? 0
        return max(value, 0)
    }
}


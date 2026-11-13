//
//  main.swift
//  autoupdatehelper
//
//  Created by Greg Neagle on 11/10/26.
//  Based on concepts and techniques here:
//  https://www.afp548.com/2026/11/09/bypass-the-ramp-update-tonight-faster-macos-updates-with-autoinstallproductkeys/
//

import Foundation
import notify

/// Returns the first element of the OS version "tuple" as an Int. Examples: 15, 26, 27
func majorOSVersion() -> Int {
    let version = ProcessInfo().operatingSystemVersion
    return version.majorVersion
}

/// Returns the macOS version as a string
func fullOSVersion() -> String {
    let version = ProcessInfo().operatingSystemVersion
    if version.patchVersion == 0 {
        return "\(version.majorVersion).\(version.minorVersion)"
    } else {
        return "\(version.majorVersion).\(version.minorVersion).\(version.patchVersion)"
    }
}

/// There's a delay between when we use CFPreferencesSetValue to write a value and when
/// it actually shows up in the prefs file. Attempt to verify it did indeed show up in the file
func verifyUpdatedAutoInstallProductKeysWereWritten(_ expectedKeys: [String]) -> Bool {
    if NSUserName() != "root" {
        log("Not running as root: could not update AutoInstallProductKeys")
        return false
    }
    var attempt = 1
    while attempt <= 10 {
        let readKeys = SUSharedPrefs.getValueForKeyFromPrefsFile("AutoInstallProductKeys") as? [String] ?? []
        if Set(expectedKeys) == Set(readKeys) {
            return true
        }
        SUSharedPrefs.sync()
        usleep(1_000_000)
        attempt += 1
    }
    log("Could not verify updated AutoInstallProductKeys were written")
    return false
}

/// Updates com.apple.SoftwareUpdate's AutoInstallProductKeys
func updateAutoInstallProductKeys(productKeys: [String], dryRun: Bool = false) {
    let currentAutoInstallProductKeys = SUSharedPrefs.get("AutoInstallProductKeys") as? [String] ?? []
    if Set(productKeys) == Set(currentAutoInstallProductKeys) {
        printAndLog("No change to AutoInstallProductKeys: \(productKeys)")
        return
    }
    if dryRun {
        print("Would set AutoInstallProductKeys to: \(productKeys)")
        return
    }
    // set the keys
    SUSharedPrefs.set("AutoInstallProductKeys", productKeys)
    printAndLog("Set AutoInstallProductKeys to: \(productKeys)")
}

func showHelpAndExit() {
    print("""
USAGE: autoupdatehelper [options]
A tool to configure macOS updates for automatic install overnight.
Version \(Info.version)

OPTIONS:
  --dry-run     Show what would be done, but make no actual changes
  -v, --version Show version info
  -h, --help    Show this help
""")
    exit(0)
}

func printProductVersionAndExit() {
    print(Info.version)
    exit(0)
}

func run() {
    // command-line option variables
    var dryRun = false

    // some simple option/flag parsing (SwiftArgumentParser is pretty heavy)
    let args = CommandLine.arguments
    let userArgs = Array(args.dropFirst())
    if userArgs.contains("-h") || userArgs.contains("--help") {
        showHelpAndExit()
    }
    if userArgs.contains("-v") || userArgs.contains("--version") {
        printProductVersionAndExit()
    }
    for arg in userArgs {
        if arg == "--dry-run" {
            dryRun = true
        } else {
            // unknown arg
            showHelpAndExit()
        }
    }

    log("### Starting run ###")
    if majorOSVersion() < 15 {
        printAndLog("macOS \(fullOSVersion()) does not support AutoInstallProductKeys, nothing to do")
        return
    }

    if NSUserName() != "root", dryRun == false {
        printAndLog("WARNING: not running as root user; no changes will be made. Setting --dry-run mode.")
        dryRun = true
    }

    // read some preferences
    var allowMajor = Preferences.allowMajor
    let updateDelayDays = Preferences.updateDelayDays

    if allowMajor, majorOSVersion() == 15 {
        printAndLog("WARNING: macOS 15 does not support auto-updates to major releases. Ignoring allowMajor preference.")
        allowMajor = false
    }

    // get product keys for items to attempt to auto-update
    let updateProcessor = UpdateProcessor(
        allowMajor: allowMajor, updateDelayDays: updateDelayDays)
    let wanted = updateProcessor.productKeysToSchedule()
    // add those keys to softwareupdate's preferences
    updateAutoInstallProductKeys(productKeys: wanted, dryRun: dryRun)

    if !dryRun {
        // check to see if they actually got written before we kick off a background check
        if verifyUpdatedAutoInstallProductKeysWereWritten(wanted) {
            // attempt to kick off a SoftwareUpdate background check
            log("Posting Darwin notification: com.apple.SoftwareUpdate.TriggerBackgroundCheck")
            notify_post("com.apple.SoftwareUpdate.TriggerBackgroundCheck")
        } else {
            printAndLog("Failed to update AutoInstallProductKeys!")
        }
    } else {
        printAndLog("dryRun mode -- no changes made")
    }
    log("### Ending run ###")
}

run()

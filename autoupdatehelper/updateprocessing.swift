//
//  updateprocessing.swift
//  autoupdatehelper
//
//  Created by Greg Neagle on 11/12/26.
//

import Foundation

/// A struct to handle figuring out which updates to add to AutoInstallProductKeys
/// with some flexibilty to allow writing tests
struct UpdateProcessor {
    var recommended: [[String:Any]]    // definied as var so tests can replace with known values
    var firstOfferDate: [String: Date] // definied as var so tests can replace with known values
    let allowMajor: Bool
    let updateDelayDays: Int

    init(allowMajor: Bool, updateDelayDays: Int) {
        self.allowMajor = allowMajor
        self.updateDelayDays = updateDelayDays
        recommended = SUSharedPrefs.get("RecommendedUpdates") as? [[String:Any]] ?? []
        firstOfferDate = SUSharedPrefs.get("FirstOfferDateDictionary") as? [String: Date] ?? [:]
    }

    private func daysAvailable(_ productKey: String) -> Int {
        if let firstOfferDate = firstOfferDate[productKey] {
            let timeInterval = Date().timeIntervalSince(firstOfferDate)
            return Int(timeInterval/(24*60*60))
        } else {
            // not in the FirstOfferDateDictionary, we'll assume the update just became available
            return 0
        }
    }

    func productKeysToSchedule() -> [String] {
        log("productKeysToSchedule: allowMajor is \(allowMajor); updateDelayDays is \(updateDelayDays)")
        var wanted = [String]()
        var minorUpdates = [String]()
        var majorUpdates = [String]()
        var safariUpdate = [String:String]()

        for update in recommended {
            guard let productKey = update["Product Key"] as? String else { continue }
            let displayName = update["Display Name"] as? String ?? ""
            let version = update["Display Version"] as? String ?? ""

            // macOS updates
            if productKey.hasPrefix("MSU_UPDATE_") {
                let daysAvailable = daysAvailable(productKey)
                var message = "\(productKey) available \(daysAvailable) days; updateDelayDays is \(updateDelayDays)"
                if productKey.hasSuffix("_major") {
                    message += "; allowMajor is \(allowMajor)"
                }
                printAndLog(message)
                if productKey.hasSuffix("_minor") {
                    if daysAvailable >= updateDelayDays {
                        minorUpdates.append(productKey)
                    } else {
                        printAndLog("Skipping \(productKey) (available \(daysAvailable) days; updateDelayDays is \(updateDelayDays))")
                    }
                }
                if allowMajor, productKey.hasSuffix("_major") {
                    if daysAvailable >= updateDelayDays {
                        majorUpdates.append(productKey)
                    } else {
                        printAndLog("Skipping \(productKey) (available \(daysAvailable) days; updateDelayDays is \(updateDelayDays))")
                    }
                }
            }
            // Command-line developer tools updates
            if let displayName = update["Display Name"] as? String {
                if displayName.hasPrefix("Command Line Tools") {
                    printAndLog("Adding \(displayName) (\(productKey)) to update list")
                    wanted.append(productKey)
                }
            }
            // Safari updates. There might be multiple Safari updates in RecommendedUpdates -
            // if so, the highest version ends up safariUpdate
            if displayName.hasPrefix("Safari") {
                let storedVersion = safariUpdate["Version"] ?? "0"
                if ProductVersion(version) > ProductVersion(storedVersion)
                {
                    safariUpdate = [
                        "Product Key": productKey,
                        "Version": version
                    ]
                }
            }
        }
        // if we found a Safari update, add to the wanted list
        if let safariProductKey = safariUpdate["Product Key"],
           let safariVersion = safariUpdate["Version"]
        {
            printAndLog("Adding Safari \(safariVersion) (\(safariProductKey)) to update list")
            wanted.append(safariProductKey)
        }
        // add macOS updates to list, adding major if allowed and any exist
        if allowMajor, !majorUpdates.isEmpty {
            wanted = wanted + majorUpdates
        } else if !minorUpdates.isEmpty {
            wanted = wanted + minorUpdates
        }
        return wanted
    }
}

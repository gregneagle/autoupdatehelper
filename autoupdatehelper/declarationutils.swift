//
//  declarationutils.swift
//  autoupdatehelper
//
//  Created by Greg Neagle on 11/13/26.
//

import Foundation
import notify

/// Returns true if there are active DDM declarations for software update
func softwareUpdateDDMDeclarationsPresent() -> Bool {
    let ddmInfoFile = "/var/db/softwareupdate/SoftwareUpdateDDMStatePersistence.plist"
    if let plistDict = NSDictionary(contentsOfFile: ddmInfoFile) as? [String: Any],
       let policyFields = plistDict["SUCorePersistedStatePolicyFields"] as? [String: Any],
       let declarations = policyFields["Declarations"] as? [String: Any]
    {
        return !declarations.isEmpty
    }
    return false
}

/// clear a stale softwareupdate's ManagedProductMarketingVersion if needed
func clearStaleSUDeclarationInfoIfNeeded() {
    let managedProductMarketingVersion = SUSharedPrefs.get("ManagedProductMarketingVersion") as? String ?? ""
    if !managedProductMarketingVersion.isEmpty {
        log("SoftwareUpdate ManagedProductMarketingVersion is \(managedProductMarketingVersion)")
        if softwareUpdateDDMDeclarationsPresent() {
            log("DDM declarations are present for SoftwareUpdate")
        } else {
            printAndLog("Clearing ManagedProductMarketingVersion from SoftwareUpdate preferences")
            SUSharedPrefs.set("ManagedProductMarketingVersion", nil)
            // since we cleared the ManagedProductMarketingVersion, a check might find a newer version
            log("Posting Darwin notification: com.apple.SoftwareUpdate.TriggerBackgroundCheck")
            notify_post("com.apple.SoftwareUpdate.TriggerBackgroundCheck")
        }
    }
}

### What is this?

autoupdatehelper is a tool written in Swift that can help you configure macOS updates to attempt to automatically install overnight.

It's based on Sam Keeley's work here:
https://www.afp548.com/2026/11/09/bypass-the-ramp-update-tonight-faster-macos-updates-with-autoinstallproductkeys/

### Why is this?

Sam provides a tool written in JavaScript to implement most of the same things this tool implements. I found the combo of JavaScript and the Objective-C bridge very difficult to follow, and I wanted to make some changes. I decided that at least for me, it would be easier to just build an equivalent tool in Swift -- one I could more easily tweak to my desires.

### Features

- `--dry-run` mode so you can see what it would do without actually making changes
- Standard macOS preferences support to configure two preferences:
  - `allowMajor` -- to allow setting up Major OS updates for auto-install
  - `updateDelayDays` -- a number of days to wait after an update is first presented before setting it up for auto-install
- Adds pending Safari and Command Line Tools updates to the auto-update list
- Logging to Apple Unified Logging

### Main differences from Sam's JavaScript tool

- Adds Safari updates to the auto-update list
- Supports local and managed preferences
- Supports delaying configuring an update for auto-install for an admin-defined number of days after the update is first available
- Logs to Apple Unified Logging
- Relies _only_ on com.apple.SoftwareUpdate's `RecommendedUpdates` -- does not consult `/System/Library/AssetsV2/com_apple_MobileAsset_MacSoftwareUpdate/com_apple_MobileAsset_MacSoftwareUpdate.xml`

### Product Identifier

This code defines a product identifier of "com.github.gregneagle.autoupdatehelper" in the productinfo.swift file. If you are going to build this tool for your own use, you may want to change that to reflect your organization.

### Preferences

You can define these preferences in `/Library/Preferences/<product_identifier>.plist` or via configuration profile:

`allowMajor`: Boolean -- If true, on macOS 26 and later will set up _major_ OS updates (upgrades) (if available) for auto-install.

`updateDelayDays`: Integer -- Number of days after an update first becomes available before the tool will set it up for auto-update

### Logging

Logging is written to Apple Unified Logging and can be read like so:
```
sudo log show --style compact --predicate 'subsystem=="<product_identifier>"'
```
If you make no changes to the product identifier, that would be:
```
sudo log show --style compact --predicate 'subsystem=="com.github.gregneagle.autoupdatehelper"'
```

### Building 

Building this tool requires XCode 15, 26, or 27.
//
//  updateprocessingTests.swift
//  autoupdateHelperTests
//
//  Created by Greg Neagle on 11/12/26.
//

import Foundation
import OSLog
import Testing

/// We do not add this testing target to the target membership of logging,swift,
/// allowing us to replace log() and printAndLog() functions so we print nothing and log nothing
/// while running the tests
func log(_ message: String, logLevel: OSLogType = .default) {
    // do nothing
}

func printAndLog(_ message: String) {
    // do nothing
}

struct updateprocessingTests {

    let goldengateMinor: [String: Any] = [
        "Display Name": "macOS 27.2.1",
        "Display Version": "27.2.1",
        "Identifier": "MSU_UPDATE_26B131_patch_27.2.1_minor",
        "MobileSoftwareUpdate": 1,
        "Product Key": "MSU_UPDATE_26B131_patch_27.2.1_minor"
    ]

    let goldengateMajor: [String: Any] = [
        "Display Name": "macOS 27.2.1",
        "Display Version": "27.2.1",
        "Identifier": "MSU_UPDATE_26B131_patch_27.2.1_major",
        "MobileSoftwareUpdate": 1,
        "Product Key": "MSU_UPDATE_26B131_patch_27.2.1_major"
    ]

    let tahoeMinor: [String: Any] = [
        "Display Name": "macOS Tahoe 26.7.2",
        "Display Version": "26.7.2",
        "Identifier": "MSU_UPDATE_25G332_patch_26.7.2_minor",
        "MobileSoftwareUpdate":  1,
        "Product Key": "MSU_UPDATE_25G332_patch_26.7.2_minor"
    ]

    let tahoeMajor: [String: Any] = [
        "Display Name": "macOS Tahoe 26.7.2",
        "Display Version": "26.7.2",
        "Identifier": "MSU_UPDATE_25G332_patch_26.7.2_major",
        "MobileSoftwareUpdate": 1,
        "Product Key": "MSU_UPDATE_25G332_patch_26.7.2_major"
    ]

    let sequoiaMinor: [String: Any] = [
        "Display Name": "macOS Sequoia 15.8.2",
        "Display Version": "15.8.2",
        "Identifier": "MSU_UPDATE_24H232_patch_15.8.2_minor",
        "MobileSoftwareUpdate": 1,
        "Product Key": "MSU_UPDATE_24H232_patch_15.8.2_minor"
    ]

    let safariTahoeAuto: [String: Any] = [
        "Display Name": "Safari",
        "Display Version": "27.2",
        "Identifier": "Safari27.2TahoeAuto",
        "Product Key": "142-16640"
    ]

    let safariSequoiaAuto26: [String: Any] = [
        "Display Name": "Safari",
        "Display Version": "26.6.1",
        "Identifier": "Safari26.6.1SequoiaAuto",
        "Product Key": "140-79446"
    ]

    let safariSequoiaAuto27: [String: Any] = [
        "Display Name": "Safari",
        "Display Version": "27.2",
        "Identifier": "Safari27.2SequoiaAuto",
        "Product Key": "142-16627"
    ]

    func productKey(_ update: [String: Any]) -> String {
        return update["Product Key"] as? String ?? ""
    }

    func threeDaysAgo() -> Date {
        return Calendar.current.date(byAdding: .day, value: -3, to: Date()) ?? Date()
    }

    /// Test that returned key list is product key for goldengate minor update
    @Test func productKeysToScheduleReturnsExpected1()  {
        let recommended = [
            goldengateMinor
        ]
        var processor = UpdateProcessor(allowMajor: false, updateDelayDays: 0)
        processor.recommended = recommended
        processor.firstOfferDate = [productKey(goldengateMinor): Date()]
        let wanted = processor.productKeysToSchedule()
        #expect(wanted == [productKey(goldengateMinor)])
    }

    /// Test that returned key list is empty because it was first seen today
    @Test func productKeysToScheduleReturnsExpected2()  {
        let recommended = [
            goldengateMinor
        ]
        var processor = UpdateProcessor(allowMajor: false, updateDelayDays: 3)
        processor.recommended = recommended
        processor.firstOfferDate = [productKey(goldengateMinor): Date()]
        let wanted = processor.productKeysToSchedule()
        #expect(wanted == [])
    }

    /// Test that returned key list is product key for goldengate minor update because it was first seen 3 days agi
    @Test func productKeysToScheduleReturnsExpected3()  {
        let recommended = [
            goldengateMinor
        ]
        var processor = UpdateProcessor(allowMajor: false, updateDelayDays: 3)
        processor.recommended = recommended
        processor.firstOfferDate = [productKey(goldengateMinor): threeDaysAgo()]
        let wanted = processor.productKeysToSchedule()
        #expect(wanted == [productKey(goldengateMinor)])
    }

    /// Test that returned key list is product key for tahoeMinor because allowMajor is false
    @Test func productKeysToScheduleReturnsExpected4()  {
        let recommended = [
            goldengateMajor,
            tahoeMinor
        ]
        var processor = UpdateProcessor(allowMajor: false, updateDelayDays: 0)
        processor.recommended = recommended
        processor.firstOfferDate = [
            productKey(goldengateMajor): Date(),
            productKey(tahoeMinor): Date()
        ]
        let wanted = processor.productKeysToSchedule()
        #expect(wanted == [productKey(tahoeMinor)])
    }

    /// Test that returned key list is product key for goldengateMajor because allowMajor is true
    @Test func productKeysToScheduleReturnsExpected5()  {
        let recommended = [
            goldengateMajor,
            tahoeMinor
        ]
        var processor = UpdateProcessor(allowMajor: true, updateDelayDays: 0)
        processor.recommended = recommended
        processor.firstOfferDate = [
            productKey(goldengateMajor): Date(),
            productKey(tahoeMinor): Date()
        ]
        let wanted = processor.productKeysToSchedule()
        #expect(wanted == [productKey(goldengateMajor)])
    }

    /// Test that returned key list contains Safari and macOS updates
    @Test func productKeysToScheduleReturnsExpected6()  {
        let recommended = [
            tahoeMinor,
            safariTahoeAuto
        ]
        var processor = UpdateProcessor(allowMajor: false, updateDelayDays: 0)
        processor.recommended = recommended
        processor.firstOfferDate = [
            productKey(tahoeMinor): Date()
        ]
        let wanted = processor.productKeysToSchedule()
        #expect(wanted == [productKey(safariTahoeAuto), productKey(tahoeMinor)])
    }

    /// Test that returned key list contains higher-versioned Safari update
    @Test func productKeysToScheduleReturnsExpected7()  {
        let recommended = [
            sequoiaMinor,
            safariSequoiaAuto26,
            safariSequoiaAuto27
        ]
        var processor = UpdateProcessor(allowMajor: false, updateDelayDays: 0)
        processor.recommended = recommended
        processor.firstOfferDate = [
            productKey(sequoiaMinor): Date()
        ]
        let wanted = processor.productKeysToSchedule()
        #expect(wanted == [productKey(safariSequoiaAuto27), productKey(sequoiaMinor)])
    }
}

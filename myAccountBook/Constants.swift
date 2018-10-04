//
//  Constants.swift
//  myAccountBook
//
//  Created by  Frank Chuang on 2017/12/23.
//  Copyright © 2017年 frankc. All rights reserved.
//

import UIKit
import Foundation

// NotificationName
let refreshRecordNotification = "refreshRecord"
let refreshChartNotification = "refreshChart"

let deviceName = UIDevice.modelName
let build = Bundle.main.infoDictionary!["CFBundleVersion"]
let version = Bundle.main.infoDictionary!["CFBundleShortVersionString"]
let majorVersion = ProcessInfo.processInfo.operatingSystemVersion.majorVersion
let minorVersion = ProcessInfo.processInfo.operatingSystemVersion.minorVersion
let patchVersion = ProcessInfo.processInfo.operatingSystemVersion.patchVersion
let systemVersion = "\(majorVersion).\(minorVersion).\(patchVersion)"

//
//  TimeLogData.swift
//  PersonalProductivityAssistant
//
//  Created by Stefan Mehnert on 23/06/16.
//  Copyright © 2016 Stefan Mehnert. All rights reserved.
//

import Foundation
import CloudKit

struct TimeLogData {
    var Uuid: UUID
    var Activity: String
    var From: Date
    var Until: Date
    var CloudSyncPending: NSNumber
    var CloudSyncStatus: CloudSyncStatus
}

//
//  NSError.swift
//  PersonalProductivityAssistant
//
//  Created by Stefan Mehnert on 18/06/16.
//  Copyright © 2016 Stefan Mehnert. All rights reserved.
//

import Foundation

extension NSError {
    func getDefaultErrorMessage() -> String {
        return "\(self.localizedDescription); \(self.localizedFailureReason); \(self.localizedRecoverySuggestion); \(self.userInfo)"
    }
}
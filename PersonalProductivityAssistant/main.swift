//
//  Main.swift
//  PersonalProductivityAssistant
//
//  Created by Stefan Mehnert on 25/12/2016.
//  Copyright © 2016 Stefan Mehnert. All rights reserved.
//

import UIKit

private func delegateClassName() -> String? {
    return NSClassFromString("XCTestCase") == nil ? NSStringFromClass(AppDelegate) : nil
}

UIApplicationMain(
        CommandLine.argc,
        UnsafeMutableRawPointer(CommandLine.unsafeArgv)
            .bindMemory(
                to: UnsafeMutablePointer<Int8>.self,
                capacity: Int(CommandLine.argc)
            ),
        nil,
        delegateClassName()
    )

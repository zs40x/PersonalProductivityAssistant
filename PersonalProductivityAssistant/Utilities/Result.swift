//
//  Result.swift
//  PersonalProductivityAssistant
//
//  Created by Stefan Mehnert on 18/06/16.
//  Copyright © 2016 Stefan Mehnert. All rights reserved.
//

import Foundation

open class Result {
    var isSucessful: Bool
    var errorMessage: String
    
    fileprivate init(isSucessful: Bool, errorMessage: String = "") {
        self.isSucessful = isSucessful
        self.errorMessage = errorMessage
    }
    
    open class func Success() -> Result {
        return Result(isSucessful: true)
    }
    
    open class func Failure(_ errorMessage: String) -> Result {
        return Result(isSucessful: false, errorMessage: errorMessage)
    }
}

open class ResultValue<T> : Result {
    var value: T?
    
    
    fileprivate init(isSucessful: Bool, errorMessage: String = "", value: T? = nil) {
        super.init(isSucessful: isSucessful, errorMessage: errorMessage)
        self.value = value
    }
    
    open class func Success(_ value: T?) -> ResultValue {
        return ResultValue(isSucessful: true, value: value)
    }
    
    open class override func Failure(_ errorMessage: String) -> ResultValue {
        return ResultValue(isSucessful: false, errorMessage: errorMessage)
    }
}

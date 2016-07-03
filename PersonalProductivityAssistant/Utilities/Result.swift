//
//  Result.swift
//  PersonalProductivityAssistant
//
//  Created by Stefan Mehnert on 18/06/16.
//  Copyright © 2016 Stefan Mehnert. All rights reserved.
//

import Foundation

public class Result {
    var isSucessful: Bool
    var errorMessage: String
    
    private init(isSucessful: Bool, errorMessage: String = "") {
        self.isSucessful = isSucessful
        self.errorMessage = errorMessage
    }
    
    public class func Success() -> Result {
        return Result(isSucessful: true)
    }
    
    public class func Failure(errorMessage: String) -> Result {
        return Result(isSucessful: false, errorMessage: errorMessage)
    }
}

public class ResultValue<T> : Result {
    var value: T?
    
    
    private init(isSucessful: Bool, errorMessage: String = "", value: T? = nil) {
        super.init(isSucessful: isSucessful, errorMessage: errorMessage)
        self.value = value
    }
    
    public class func Success(value: T?) -> ResultValue {
        return ResultValue(isSucessful: true, value: value)
    }
    
    public class override func Failure(errorMessage: String) -> ResultValue {
        return ResultValue(isSucessful: false, errorMessage: errorMessage)
    }
}
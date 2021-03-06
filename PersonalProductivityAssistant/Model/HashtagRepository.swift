//
//  HashtagRepository.swift
//  PersonalProductivityAssistant
//
//  Created by Stefan Mehnert on 04/07/16.
//  Copyright © 2016 Stefan Mehnert. All rights reserved.
//

import Foundation
import CoreData

class HashtagRepository {
    
    fileprivate var model = PPAModel.sharedInstance()
    
    func getAll() -> ResultValue<[Hashtag]> {
        
        do {
            let allHashtags = try model.Hashtags.getAllHashtags()
            return ResultValue.Success(allHashtags)
        } catch let error as NSError {
            return ResultValue.Failure(error.getDefaultErrorMessage())
        }
    }
    
    func addNew(withName name: String) -> ResultValue<Hashtag> {
        
        do {
            let newHashtag = model.Hashtags.createHashtag(withName: name)
            try model.save()
            
            return ResultValue.Success(newHashtag)
        }
        catch let error as NSError {
            return ResultValue.Failure(error.getDefaultErrorMessage())
        }
    }
}

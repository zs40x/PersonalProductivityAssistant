//
//  UIViewController.swift
//  PersonalProductivityAssistant
//
//  Created by Stefan Mehnert on 12/07/16.
//  Copyright © 2016 Stefan Mehnert. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    func showAlertDialog(errorMessage: String) {
        let alertController =
            UIAlertController(
                title: "PPA",
                message: errorMessage,
                preferredStyle: UIAlertControllerStyle.Alert)
        
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
        
        if var topController = UIApplication.sharedApplication().keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            
            topController.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    func showNavigationBar() {
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func hideNavigationBar() {
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
}
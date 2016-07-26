//
//  CalenderView.swift
//  PersonalProductivityAssistant
//
//  Created by Stefan Mehnert on 26/07/16.
//  Copyright © 2016 Stefan Mehnert. All rights reserved.
//

import UIKit

class CalenderView: UIView {

    var view: UIView!
    
    var nibName: String = "CalenderView"
    
    
    internal override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    
    // MARK: Helper Methods
    func setupView() {
        
        self.view = UINib(nibName: nibName, bundle: NSBundle(forClass: self.dynamicType)).instantiateWithOwner(self, options: nil)[0] as! UIView
        
        self.view.frame = bounds
        self.view.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        
        self.addSubview(self.view)
    }
}

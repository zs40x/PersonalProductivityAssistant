//
//  CalenderHeaderView.swift
//  PersonalProductivityAssistant
//
//  Created by Stefan Mehnert on 28/07/16.
//  Copyright © 2016 Stefan Mehnert. All rights reserved.
//

import UIKit

class CalendarHeaderView: UIView {
    
    lazy var monthLabel : UILabel = {
        
        let lbl = UILabel()
        lbl.textAlignment = NSTextAlignment.center
        lbl.font = UIFont.init(name: "Helvetica", size: 20.0)
        lbl.textColor = UIColor.gray
        
        self.addSubview(lbl)
        
        return lbl
    }()
    
    lazy var dayLabelContainerView : UIView = {
        
        let v = UIView()
        
        let formatter : DateFormatter = DateFormatter()
        
        for index in 1...7 {
            
            let day : NSString = formatter.weekdaySymbols[index % 7] as NSString
            
            let weekdayLabel = UILabel()
            
            weekdayLabel.font = UIFont.init(name: "Helvetica", size: 14.0)
            
            weekdayLabel.text = day.substring(to: 2).uppercased()
            weekdayLabel.textColor = UIColor.gray
            weekdayLabel.textAlignment = NSTextAlignment.center
            
            v.addSubview(weekdayLabel)
        }
        
        self.addSubview(v)
        
        return v
        
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        
        var frm = self.bounds
        frm.origin.y += 5.0
        frm.size.height = 40.0
        
        self.monthLabel.frame = frm
        
        
        var labelFrame = CGRect(x: 0.0, y: self.bounds.size.height / 2.0, width: self.bounds.size.width / 7.0, height: self.bounds.size.height / 2.0)
        
        for lbl in self.dayLabelContainerView.subviews {
            
            lbl.frame = labelFrame
            labelFrame.origin.x += labelFrame.size.width
        }
        
        
        
    }
    
}

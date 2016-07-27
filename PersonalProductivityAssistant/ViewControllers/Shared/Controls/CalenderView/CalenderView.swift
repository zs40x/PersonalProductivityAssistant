//
//  CalenderView.swift
//  PersonalProductivityAssistant
//
//  Created by Stefan Mehnert on 26/07/16.
//  Copyright © 2016 Stefan Mehnert. All rights reserved.
//

import UIKit

class CalenderView: UIView {

    @IBOutlet weak var collectionView: UICollectionView!
    var view: UIView!
    
    var nibName: String = "CalenderView"
    private var DaysInMonth = [String]()
    
    
    internal override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    internal required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    private func commonInit() {
        self.setupView()
        self.setupCollectionView()
        self.setupCalenderDataSource()
    }
    
    
    
    
    // MARK: Helper Methods
    private func setupView() {
        
        self.view = UINib(nibName: nibName, bundle: NSBundle(forClass: self.dynamicType)).instantiateWithOwner(self, options: nil)[0] as! UIView
        
        self.view.frame = bounds
        self.view.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        
        self.addSubview(self.view)
    }
    
    private func setupCollectionView() {
        
        let nib = UINib(nibName: "CalenderViewCell", bundle: nil)
        self.collectionView.registerNib(nib, forCellWithReuseIdentifier: "calenderViewCell")
        
        self.collectionView.dataSource = self
    }
}

extension CalenderView : UICollectionViewDataSource {
    
    
    
    private func setupCalenderDataSource() {
        
        1.stride(to: NSDate().daysInMonth(), by: 1).forEach {
            DaysInMonth.append(String($0))
        }
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return DaysInMonth.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("calenderViewCell", forIndexPath: indexPath) as! CalenderViewCell
        
        cell.label.text = DaysInMonth[indexPath.row]
        cell.label.textColor = UIColor.whiteColor()
        
        return cell
    }

}

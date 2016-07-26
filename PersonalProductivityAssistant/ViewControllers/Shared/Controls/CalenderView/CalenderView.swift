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
    
    
    internal override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    internal required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    
    // MARK: Helper Methods
    func setupView() {
        
        self.view = UINib(nibName: nibName, bundle: NSBundle(forClass: self.dynamicType)).instantiateWithOwner(self, options: nil)[0] as! UIView
        
        self.view.frame = bounds
        self.view.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        
        self.addSubview(self.view)
        
        let nib = UINib(nibName: "CalenderViewCell", bundle: nil)
        self.collectionView.registerNib(nib, forCellWithReuseIdentifier: "calenderViewCell")
        
        self.collectionView.dataSource = self
    }
}

extension CalenderView : UICollectionViewDataSource {
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 40
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("calenderViewCell", forIndexPath: indexPath) as! CalenderViewCell
        
        cell.label.text = "test"
        cell.label.textColor = UIColor.whiteColor()
        
        return cell
    }

}

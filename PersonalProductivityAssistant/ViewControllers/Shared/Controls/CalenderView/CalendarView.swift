//
//  CalenderView.swift
//  PersonalProductivityAssistant
//
//  Created by Stefan Mehnert on 26/07/16.
//  Copyright © 2016 Stefan Mehnert. All rights reserved.
//

import UIKit


let cellReuseIdentifier = "CalendarDayCell"

let NUMBER_OF_DAYS_IN_WEEK = 7
let MAXIMUM_NUMBER_OF_ROWS = 6

let HEADER_DEFAULT_HEIGHT : CGFloat = 70.0


let FIRST_DAY_INDEX = 0
let NUMBER_OF_DAYS_INDEX = 1
let DATE_SELECTED_INDEX = 2


protocol CalendarViewDataSource {
    
    func startDate() -> NSDate?
    func endDate() -> NSDate?
    func timeLogs() -> [TimeLog]?
}

@objc protocol CalendarViewDelegate {
    
    optional func calendar(calendar : CalendarView, canSelectDate date : NSDate) -> Bool
    func calendar(calendar : CalendarView, didScrollToMonth date : NSDate) -> Void
    func calendar(calendar : CalendarView, didSelectDate date : NSDate, with selectedTimelogs: [TimeLog])
    optional func calendar(calendar : CalendarView, didDeselectDate date : NSDate) -> Void
}


class CalendarView: UIView, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var dataSource  : CalendarViewDataSource? {
        didSet {
            self.timeLogs = self.dataSource?.timeLogs()
        }
    }
    var delegate    : CalendarViewDelegate?
    
    lazy var gregorian : NSCalendar = {
        
        let cal = NSCalendar(identifier: NSCalendarIdentifierGregorian)!
        
        cal.timeZone = NSTimeZone(abbreviation: "UTC")!
        
        return cal
    }()
    
    var calendar : NSCalendar {
        return self.gregorian
    }
    
    var direction : UICollectionViewScrollDirection = .Horizontal {
        didSet {
            if let layout = self.calendarView.collectionViewLayout as? CalendarFlowLayout {
                layout.scrollDirection = direction
                self.calendarView.reloadData()
            }
        }
    }
    
    private var startDateCache : NSDate = NSDate()
    private var endDateCache : NSDate = NSDate()
    private var startOfMonthCache : NSDate = NSDate()
    private var todayIndexPath : NSIndexPath?
    var displayDate : NSDate?
    
    private(set) var selectedIndexPaths : [NSIndexPath] = [NSIndexPath]()
    private(set) var selectedDates : [NSDate] = [NSDate]()
    
    
    private var timeLogsByIndexPath = [NSIndexPath:[TimeLog]]()
    private var timeLogs : [TimeLog]? {
        
        didSet {
            
            timeLogsByIndexPath = [NSIndexPath:[TimeLog]]()
            
            guard let timeLogs = self.timeLogs else { return }
            
            let secondsFromGMTDifference = NSTimeInterval(NSTimeZone.localTimeZone().secondsFromGMT)
            
            for timeLog in timeLogs {
                
                guard let dateFrom = timeLog.from else { continue }
                
                let startDate = dateFrom.dateByAddingTimeInterval(secondsFromGMTDifference)
                
                
                let distanceFromStartComponent =
                    self.gregorian.components(
                        [.Month, .Day], fromDate: startOfMonthCache, toDate: startDate, options: NSCalendarOptions() )
                
                let indexPath =
                    NSIndexPath(forItem: distanceFromStartComponent.day, inSection: distanceFromStartComponent.month)
                
                print(startOfMonthCache)
                print("\(distanceFromStartComponent.day).\(distanceFromStartComponent.month).\(distanceFromStartComponent.year)")
                
                if var timeLogsInIndexPath : [TimeLog] = timeLogsByIndexPath[indexPath] {
                    timeLogsInIndexPath.append(timeLog)
                } else {
                    timeLogsByIndexPath[indexPath] = [timeLog]
                }
            }
        }
    }
    
    
    lazy var headerView : CalendarHeaderView = {
        
        let hv = CalendarHeaderView(frame:CGRectZero)
        
        return hv
        
    }()
    
    lazy var calendarView : UICollectionView = {
        
        let layout = CalendarFlowLayout()
        layout.scrollDirection = self.direction;
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
        let cv = UICollectionView(frame: CGRectZero, collectionViewLayout: layout)
        cv.dataSource = self
        cv.delegate = self
        cv.pagingEnabled = true
        cv.backgroundColor = UIColor.clearColor()
        cv.showsHorizontalScrollIndicator = false
        cv.showsVerticalScrollIndicator = false
        cv.allowsMultipleSelection = true
        
        return cv
        
    }()
    
    override var frame: CGRect {
        didSet {
            
            let heigh = frame.size.height - HEADER_DEFAULT_HEIGHT
            let width = frame.size.width
            
            self.headerView.frame   = CGRect(x:0.0, y:0.0, width: frame.size.width, height:HEADER_DEFAULT_HEIGHT)
            self.calendarView.frame = CGRect(x:0.0, y:HEADER_DEFAULT_HEIGHT, width: width, height: heigh)
            
            let layout = self.calendarView.collectionViewLayout as! UICollectionViewFlowLayout
            layout.itemSize = CGSizeMake(width / CGFloat(NUMBER_OF_DAYS_IN_WEEK), heigh / CGFloat(MAXIMUM_NUMBER_OF_ROWS))
            
        }
    }
    
    
    
    override init(frame: CGRect) {
        super.init(frame : CGRectMake(0.0, 0.0, 200.0, 200.0))
        self.initialSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        self.initialSetup()
    }
    
    
    
    // MARK: Helper Methods
    private func initialSetup() {
        
        self.clipsToBounds = true
        
        self.calendarView.registerClass(CalendarDayCell.self, forCellWithReuseIdentifier: cellReuseIdentifier)
        
        
        self.addSubview(self.headerView)
        self.addSubview(self.calendarView)
    }
    
    
    
    // MARK: UICollectionViewDataSource
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        
        guard let startDate = self.dataSource?.startDate(), endDate = self.dataSource?.endDate() else {
            return 0
        }
        
        startDateCache = startDate
        endDateCache = endDate
        
        // check if the dates are in correct order
        if self.gregorian.compareDate(startDate, toDate: endDate, toUnitGranularity: .Nanosecond) != NSComparisonResult.OrderedAscending {
            return 0
        }
        
        print("\(startDate)-\(endDate)")
        
        let firstDayOfStartMonth = self.gregorian.components( [.Era, .Year, .Month], fromDate: startDateCache)
        firstDayOfStartMonth.day = 1
        
        guard let dateFromDayOneComponents = self.gregorian.dateFromComponents(firstDayOfStartMonth) else {
            return 0
        }
        
        startOfMonthCache = dateFromDayOneComponents
        print("SOMD:\(startOfMonthCache)")
        
        
        let today = NSDate()
        
        if  startOfMonthCache.compare(today) == NSComparisonResult.OrderedAscending &&
            endDateCache.compare(today) == NSComparisonResult.OrderedDescending {
            
            let differenceFromTodayComponents = self.gregorian.components([NSCalendarUnit.Month, NSCalendarUnit.Day], fromDate: startOfMonthCache, toDate: today, options: NSCalendarOptions())
            
            self.todayIndexPath = NSIndexPath(forItem: differenceFromTodayComponents.day, inSection: differenceFromTodayComponents.month)
            
        }
        
        let differenceComponents = self.gregorian.components(NSCalendarUnit.Month, fromDate: startDateCache, toDate: endDateCache, options: NSCalendarOptions())
        
        
        return differenceComponents.month + 1 // if we are for example on the same month and the difference is 0 we still need 1 to display it
        
    }
    
    var monthInfo : [Int:[Int]] = [Int:[Int]]()
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        let monthOffsetComponents = NSDateComponents()
        
        
        // offset by the number of months
        monthOffsetComponents.month = section;
        
        guard let correctMonthForSectionDate = self.gregorian.dateByAddingComponents(monthOffsetComponents, toDate: startOfMonthCache, options: NSCalendarOptions()) else {
            return 0
        }
        
        let numberOfDaysInMonth = self.gregorian.rangeOfUnit(.Day, inUnit: .Month, forDate: correctMonthForSectionDate).length
        
        var firstWeekdayOfMonthIndex = self.gregorian.component(NSCalendarUnit.Weekday, fromDate: correctMonthForSectionDate)
        firstWeekdayOfMonthIndex = firstWeekdayOfMonthIndex - 1 // firstWeekdayOfMonthIndex should be 0-Indexed
        firstWeekdayOfMonthIndex = (firstWeekdayOfMonthIndex + 6) % 7 // push it modularly so that we take it back one day so that the first day is Monday instead of Sunday which is the default
        
        monthInfo[section] = [firstWeekdayOfMonthIndex, numberOfDaysInMonth]
        
        return NUMBER_OF_DAYS_IN_WEEK * MAXIMUM_NUMBER_OF_ROWS // 7 x 6 = 42
    }
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let dayCell =
            collectionView.dequeueReusableCellWithReuseIdentifier(cellReuseIdentifier, forIndexPath: indexPath) as! CalendarDayCell
        let currentMonthInfo : [Int] = monthInfo[indexPath.section]!
        
        let fdIndex = currentMonthInfo[FIRST_DAY_INDEX]
        let nDays = currentMonthInfo[NUMBER_OF_DAYS_INDEX]
        
        let fromStartOfMonthIndexPath = NSIndexPath(forItem: indexPath.item - fdIndex, inSection: indexPath.section) // if the first is wednesday, add 2
        
        guard self.dataSource != nil else {
            dayCell.textLabel.text="-"
            return dayCell
        }
        
        if indexPath.item >= fdIndex && indexPath.item < fdIndex + nDays {
            dayCell.textLabel.text = String(fromStartOfMonthIndexPath.item + 1)
            dayCell.hidden = false
            
        }
        else {
            dayCell.textLabel.text = ""
            dayCell.hidden = true
        }
        
        dayCell.selected = selectedIndexPaths.contains(indexPath)
        
        if indexPath.section == 0 && indexPath.item == 0 {
            self.scrollViewDidEndDecelerating(collectionView)
        }
        
        if let idx = todayIndexPath {
            dayCell.isToday = (idx.section == indexPath.section && idx.item + fdIndex == indexPath.item)
        }
        
        if let timeLogsForDay = timeLogsByIndexPath[fromStartOfMonthIndexPath] {
            dayCell.eventsCount = timeLogsForDay.count
           
        } else {
            dayCell.eventsCount = 0
        }
        
        return dayCell
    }
    
    // MARK: UIScrollViewDelegate
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        self.calculateDateBasedOnScrollViewPosition(scrollView)
    }
    
    func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        self.calculateDateBasedOnScrollViewPosition(scrollView)
    }
    
    
    func calculateDateBasedOnScrollViewPosition(scrollView: UIScrollView) {
        
        let cvbounds = self.calendarView.bounds
        
        var page : Int = Int(floor(self.calendarView.contentOffset.x / cvbounds.size.width))
        
        page = page > 0 ? page : 0
        
        let monthsOffsetComponents = NSDateComponents()
        monthsOffsetComponents.month = page
        
        guard let delegate = self.delegate else {
            return
        }
        
        
        guard let yearDate = self.gregorian.dateByAddingComponents(monthsOffsetComponents, toDate: self.startOfMonthCache, options: NSCalendarOptions()) else {
            return
        }
        
        let month = self.gregorian.component(NSCalendarUnit.Month, fromDate: yearDate) // get month
        
        let monthName = NSDateFormatter().monthSymbols[(month-1) % 12] // 0 indexed array
        
        let year = self.gregorian.component(NSCalendarUnit.Year, fromDate: yearDate)
        
        
        self.headerView.monthLabel.text = monthName + " " + String(year)
        
        self.displayDate = yearDate
        
        
        delegate.calendar(self, didScrollToMonth: yearDate)
        
    }
    
    
    // MARK: UICollectionViewDelegate
    
    private var dateBeingSelectedByUser : NSDate?
    func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        
        let currentMonthInfo : [Int] = monthInfo[indexPath.section]!
        let firstDayInMonth = currentMonthInfo[FIRST_DAY_INDEX]
        
        let offsetComponents = NSDateComponents()
        offsetComponents.month = indexPath.section
        offsetComponents.day = indexPath.item - firstDayInMonth
        
        
        
        if let dateUserSelected = self.gregorian.dateByAddingComponents(offsetComponents, toDate: startOfMonthCache, options: NSCalendarOptions()) {
            
            dateBeingSelectedByUser = dateUserSelected
            
            // Optional protocol method (the delegate can "object")
            if let canSelectFromDelegate = delegate?.calendar?(self, canSelectDate: dateUserSelected) {
                return canSelectFromDelegate
            }
            
            return true // it can select any date by default
            
        }
        
        return false // if date is out of scope
        
    }
    
    func selectDate(date : NSDate) {
        
        guard let indexPath = self.indexPathForDate(date) else {
            return
        }
        
        guard self.calendarView.indexPathsForSelectedItems()?.contains(indexPath) == false else {
            return
        }
        
        self.calendarView.selectItemAtIndexPath(indexPath, animated: false, scrollPosition: .None)
        
        selectedIndexPaths.append(indexPath)
        selectedDates.append(date)
        
    }
    
    func deselectDate(date : NSDate) {
        
        guard let indexPath = self.indexPathForDate(date) else {
            return
        }
        
        guard self.calendarView.indexPathsForSelectedItems()?.contains(indexPath) == true else {
            return
        }
        
        
        self.calendarView.deselectItemAtIndexPath(indexPath, animated: false)
        
        guard let index = selectedIndexPaths.indexOf(indexPath) else {
            return
        }
        
        
        selectedIndexPaths.removeAtIndex(index)
        selectedDates.removeAtIndex(index)
        
        
    }
    
    func indexPathForDate(date : NSDate) -> NSIndexPath? {
        
        let distanceFromStartComponent = self.gregorian.components( [.Month, .Day], fromDate:startOfMonthCache, toDate: date, options: NSCalendarOptions() )
        
        guard let currentMonthInfo : [Int] = monthInfo[distanceFromStartComponent.month] else {
            return nil
        }
        
        
        let item = distanceFromStartComponent.day + currentMonthInfo[FIRST_DAY_INDEX]
        let indexPath = NSIndexPath(forItem: item, inSection: distanceFromStartComponent.month)
        
        return indexPath
        
    }
    
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        guard let dateBeingSelectedByUser = dateBeingSelectedByUser else {
            return
        }
        
        let currentMonthInfo : [Int] = monthInfo[indexPath.section]!
        
        let fromStartOfMonthIndexPath = NSIndexPath(forItem: indexPath.item - currentMonthInfo[FIRST_DAY_INDEX], inSection: indexPath.section)
        
        var timeLogsOnSelectedDate = [TimeLog]()
        
        if let timeLogsOnDate = self.timeLogsByIndexPath[indexPath] {
            timeLogsOnSelectedDate = timeLogsOnDate
        }
        
        delegate?.calendar(self, didSelectDate: dateBeingSelectedByUser, with: timeLogsOnSelectedDate)
        
        // Update model
        selectedIndexPaths.append(indexPath)
        selectedDates.append(dateBeingSelectedByUser)
    }
    
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        
        guard let dateBeingSelectedByUser = dateBeingSelectedByUser else {
            return
        }
        
        guard let index = selectedIndexPaths.indexOf(indexPath) else {
            return
        }
        
        delegate?.calendar?(self, didDeselectDate: dateBeingSelectedByUser)
        
        selectedIndexPaths.removeAtIndex(index)
        selectedDates.removeAtIndex(index)
        
    }
    
    
    func reloadData() {
        self.timeLogs = self.dataSource?.timeLogs()
        
        self.calendarView.reloadData()
    }
    
    
    func setDisplayDate(date : NSDate, animated: Bool) {
        
        if let dispDate = self.displayDate {
            
            // skip is we are trying to set the same date
            if  date.compare(dispDate) == NSComparisonResult.OrderedSame {
                return
            }
            
            
            // check if the date is within range
            if  date.compare(startDateCache) == NSComparisonResult.OrderedAscending ||
                date.compare(endDateCache) == NSComparisonResult.OrderedDescending   {
                return
            }
            
            
            let difference = self.gregorian.components([NSCalendarUnit.Month], fromDate: startOfMonthCache, toDate: date, options: NSCalendarOptions())
            
            let distance : CGFloat = CGFloat(difference.month) * self.calendarView.frame.size.width
            
            self.calendarView.setContentOffset(CGPoint(x: distance, y: 0.0), animated: animated)
        }
    }
}
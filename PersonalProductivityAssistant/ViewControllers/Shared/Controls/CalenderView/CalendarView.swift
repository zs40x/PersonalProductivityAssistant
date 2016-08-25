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
    
    func startDate() -> Date?
    func endDate() -> Date?
}

@objc protocol CalendarViewDelegate {
    
    @objc optional func calendar(_ calendar : CalendarView, canSelectDate date : Date) -> Bool
    func calendar(_ calendar : CalendarView, didScrollToMonth date : Date) -> Void
    func calendar(_ calendar : CalendarView, didSelectDate date : Date, with selectedTimelogs: [TimeLog])
    @objc optional func calendar(_ calendar : CalendarView, didDeselectDate date : Date) -> Void
}


class CalendarView: UIView, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var dataSource  : CalendarViewDataSource?
    var delegate    : CalendarViewDelegate?
    
    lazy var gregorian : NSCalendar = {
        
        let cal = NSCalendar(identifier: NSCalendar.Identifier.gregorian)!
        
        cal.timeZone = NSTimeZone(abbreviation: "UTC")! as TimeZone
        
        return cal
    }()
    
    var calendar : NSCalendar {
        return self.gregorian
    }
    
    var direction : UICollectionViewScrollDirection = .horizontal {
        didSet {
            if let layout = self.calendarView.collectionViewLayout as? CalendarFlowLayout {
                layout.scrollDirection = direction
                self.calendarView.reloadData()
            }
        }
    }
    
    private var startDateCache : Date = Date()
    private var endDateCache : Date = Date()
    private var startOfMonthCache : Date = Date()
    private var todayIndexPath : IndexPath?
    var displayDate : Date?
    
    private(set) var selectedIndexPaths : [IndexPath] = [IndexPath]()
    private(set) var selectedDates : [Date] = [Date]()
    
    
    private var timeLogsByIndexPath = [IndexPath:[TimeLog]]()
    
    var timeLogs : [TimeLog]? {
        
        didSet {
            
            timeLogsByIndexPath = [IndexPath:[TimeLog]]()
            
            guard let currentTimeLogs = self.timeLogs else {
                return
            }
            
            let secondsFromGMTDifference = TimeInterval(NSTimeZone.local.secondsFromGMT())
            
            for timeLog in currentTimeLogs {
                
                guard let dateFrom = timeLog.from else { continue }
                
                let startDate = dateFrom.addingTimeInterval(secondsFromGMTDifference)
                
                let distanceFromStartComponent =
                    self.gregorian.components(
                        [.monthSymbols, .firstWeekday], from: startOfMonthCache, to: startDate, options: Calendar() )
                
                let indexPath =
                    IndexPath(item: distanceFromStartComponent.day, section: distanceFromStartComponent.month)
                
                if var timeLogsInIndexPath : [TimeLog] = timeLogsByIndexPath[indexPath] {
                    timeLogsInIndexPath.append(timeLog)
                    timeLogsByIndexPath[indexPath] = timeLogsInIndexPath
                } else {
                    timeLogsByIndexPath[indexPath] = [timeLog]
                }
            }
        }
    }
    
    
    lazy var headerView : CalendarHeaderView = {
        
        let hv = CalendarHeaderView(frame:CGRect.zero)
        
        return hv
        
    }()
    
    lazy var calendarView : UICollectionView = {
        
        let layout = CalendarFlowLayout()
        layout.scrollDirection = self.direction;
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
        let cv = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        cv.dataSource = self
        cv.delegate = self
        cv.isPagingEnabled = true
        cv.backgroundColor = UIColor.clear
        cv.showsHorizontalScrollIndicator = false
        cv.showsVerticalScrollIndicator = false
        cv.allowsMultipleSelection = false
        
        return cv
        
    }()
    
    override var frame: CGRect {
        didSet {
            
            let heigh = frame.size.height - HEADER_DEFAULT_HEIGHT
            let width = frame.size.width
            
            self.headerView.frame   = CGRect(x:0.0, y:0.0, width: frame.size.width, height:HEADER_DEFAULT_HEIGHT)
            self.calendarView.frame = CGRect(x:0.0, y:HEADER_DEFAULT_HEIGHT, width: width, height: heigh)
            
            let layout = self.calendarView.collectionViewLayout as! UICollectionViewFlowLayout
            layout.itemSize = CGSize(width: width / CGFloat(NUMBER_OF_DAYS_IN_WEEK), height: heigh / CGFloat(MAXIMUM_NUMBER_OF_ROWS))
            
        }
    }
    
    
    
    override init(frame: CGRect) {
        super.init(frame : CGRect(x: 0.0, y: 0.0, width: 200.0, height: 200.0))
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
        
        self.calendarView.register(CalendarDayCell.self, forCellWithReuseIdentifier: cellReuseIdentifier)
        
        
        self.addSubview(self.headerView)
        self.addSubview(self.calendarView)
    }
    
    
    
    // MARK: UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        guard let startDate = self.dataSource?.startDate(), let endDate = self.dataSource?.endDate() else {
            return 0
        }
        
        startDateCache = startDate
        endDateCache = endDate
        
        // check if the dates are in correct order
        if self.gregorian.compare(startDate, to: endDate, toUnitGranularity: .nanosecond) != ComparisonResult.orderedAscending {
            return 0
        }
        
        let firstDayOfStartMonth = self.gregorian.components( [.eraSymbols, .year, .monthSymbols], from: startDateCache)
        firstDayOfStartMonth.day = 1
        
        guard let dateFromDayOneComponents = self.gregorian.date(from: firstDayOfStartMonth) else {
            return 0
        }
        
        startOfMonthCache = dateFromDayOneComponents

        let today = Date()
        
        if  startOfMonthCache.compare(today) == ComparisonResult.orderedAscending &&
            endDateCache.compare(today) == ComparisonResult.orderedDescending {
            
            let differenceFromTodayComponents = self.gregorian.components([Calendar.monthSymbols, Calendar.firstWeekday], from: startOfMonthCache, to: today, options: Calendar())
            
            self.todayIndexPath = IndexPath(item: differenceFromTodayComponents.day, section: differenceFromTodayComponents.month)
            
        }
        
        let differenceComponents = self.gregorian.components(Calendar.monthSymbols, from: startDateCache, to: endDateCache, options: Calendar())
        
        
        return differenceComponents.month + 1 // if we are for example on the same month and the difference is 0 we still need 1 to display it
        
    }
    
    var monthInfo : [Int:[Int]] = [Int:[Int]]()
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        var monthOffsetComponents = DateComponents()
        
        
        // offset by the number of months
        monthOffsetComponents.month = section;
        
        guard let correctMonthForSectionDate = self.gregorian.date(byAdding: monthOffsetComponents, to: startOfMonthCache, options: Calendar()) else {
            return 0
        }
        
        let numberOfDaysInMonth = self.gregorian.range(of: .firstWeekday, in: .monthSymbols, for: correctMonthForSectionDate).length
        
        var firstWeekdayOfMonthIndex = self.gregorian.component(Calendar.firstWeekday, from: correctMonthForSectionDate)
        firstWeekdayOfMonthIndex = firstWeekdayOfMonthIndex - 1 // firstWeekdayOfMonthIndex should be 0-Indexed
        firstWeekdayOfMonthIndex = (firstWeekdayOfMonthIndex + 6) % 7 // push it modularly so that we take it back one day so that the first day is Monday instead of Sunday which is the default
        
        monthInfo[section] = [firstWeekdayOfMonthIndex, numberOfDaysInMonth]
        
        return NUMBER_OF_DAYS_IN_WEEK * MAXIMUM_NUMBER_OF_ROWS // 7 x 6 = 42
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let dayCell =
            collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath) as! CalendarDayCell
        let currentMonthInfo : [Int] = monthInfo[(indexPath as NSIndexPath).section]!
        
        let fdIndex = currentMonthInfo[FIRST_DAY_INDEX]
        let nDays = currentMonthInfo[NUMBER_OF_DAYS_INDEX]
        
        let fromStartOfMonthIndexPath = IndexPath(item: (indexPath as NSIndexPath).item - fdIndex, section: (indexPath as NSIndexPath).section) // if the first is wednesday, add 2
        
        guard self.dataSource != nil else {
            dayCell.textLabel.text="-"
            return dayCell
        }
        
        if (indexPath as NSIndexPath).item >= fdIndex && (indexPath as NSIndexPath).item < fdIndex + nDays {
            dayCell.textLabel.text = String((fromStartOfMonthIndexPath as NSIndexPath).item + 1)
            dayCell.isHidden = false
            
        }
        else {
            dayCell.textLabel.text = ""
            dayCell.isHidden = true
        }
        
        dayCell.isSelected = selectedIndexPaths.contains(indexPath)
        
        if (indexPath as NSIndexPath).section == 0 && (indexPath as NSIndexPath).item == 0 {
            self.scrollViewDidEndDecelerating(collectionView)
        }
        
        if let idx = todayIndexPath {
            dayCell.isToday = ((idx as NSIndexPath).section == (indexPath as NSIndexPath).section && (idx as NSIndexPath).item + fdIndex == (indexPath as NSIndexPath).item)
        }
        
        if let timeLogsForDay = timeLogsByIndexPath[fromStartOfMonthIndexPath] {
            dayCell.eventsCount = timeLogsForDay.count
           
        } else {
            dayCell.eventsCount = 0
        }
        
        return dayCell
    }
    
    // MARK: UIScrollViewDelegate
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.calculateDateBasedOnScrollViewPosition(scrollView)
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        self.calculateDateBasedOnScrollViewPosition(scrollView)
    }
    
    
    private var previousYearDate: Date?
    func calculateDateBasedOnScrollViewPosition(_ scrollView: UIScrollView) {
        
        let cvbounds = self.calendarView.bounds
        
        var page : Int = Int(floor(self.calendarView.contentOffset.x / cvbounds.size.width))
        
        page = page > 0 ? page : 0
        
        var monthsOffsetComponents = DateComponents()
        monthsOffsetComponents.month = page
        
        guard let delegate = self.delegate else {
            return
        }
        
        
        guard let yearDate = self.gregorian.date(byAdding: monthsOffsetComponents, to: self.startOfMonthCache, options: Calendar()) else {
            return
        }
        
        let month = self.gregorian.component(Calendar.monthSymbols, from: yearDate) // get month
        let monthName = DateFormatter().monthSymbols[(month-1) % 12] // 0 indexed array
        let year = self.gregorian.component(Calendar.year, from: yearDate)
        
        
        self.headerView.monthLabel.text = monthName + " " + String(year)
        self.displayDate = yearDate
        
        
        if previousYearDate != nil {
            if previousYearDate! != yearDate {
                delegate.calendar(self, didScrollToMonth: yearDate)
            }
        } else {
            delegate.calendar(self, didScrollToMonth: yearDate)
        }
        
        previousYearDate = yearDate
    }
    
    
    // MARK: UICollectionViewDelegate
    
    private var dateBeingSelectedByUser : Date?
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        
        let currentMonthInfo : [Int] = monthInfo[(indexPath as NSIndexPath).section]!
        let firstDayInMonth = currentMonthInfo[FIRST_DAY_INDEX]
        
        var offsetComponents = DateComponents()
        offsetComponents.month = (indexPath as NSIndexPath).section
        offsetComponents.day = (indexPath as NSIndexPath).item - firstDayInMonth
        
        
        
        if let dateUserSelected = self.gregorian.date(byAdding: offsetComponents, to: startOfMonthCache, options: Calendar()) {
            
            dateBeingSelectedByUser = dateUserSelected
            
            // Optional protocol method (the delegate can "object")
            if let canSelectFromDelegate = delegate?.calendar?(self, canSelectDate: dateUserSelected) {
                return canSelectFromDelegate
            }
            
            return true // it can select any date by default
            
        }
        
        return false // if date is out of scope
        
    }
    
    func selectDate(_ date : Date) {
        
        guard let indexPath = self.indexPathForDate(date) else {
            return
        }
        
        guard self.calendarView.indexPathsForSelectedItems?.contains(indexPath) == false else {
            return
        }
        
        self.calendarView.selectItem(at: indexPath, animated: false, scrollPosition: UICollectionViewScrollPosition())
        
        selectedIndexPaths.append(indexPath)
        selectedDates.append(date)
        
    }
    
    func deselectDate(_ date : Date) {
        
        guard let indexPath = self.indexPathForDate(date) else {
            return
        }
        
        guard self.calendarView.indexPathsForSelectedItems?.contains(indexPath) == true else {
            return
        }
        
        
        self.calendarView.deselectItem(at: indexPath, animated: false)
        
        guard let index = selectedIndexPaths.index(of: indexPath) else {
            return
        }
        
        
        selectedIndexPaths.remove(at: index)
        selectedDates.remove(at: index)
        
        
    }
    
    func indexPathForDate(_ date : Date) -> IndexPath? {
        
        let distanceFromStartComponent = self.gregorian.components( [.monthSymbols, .firstWeekday], from:startOfMonthCache, to: date, options: Calendar() )
        
        guard let currentMonthInfo : [Int] = monthInfo[distanceFromStartComponent.month] else {
            return nil
        }
        
        
        let item = distanceFromStartComponent.day + currentMonthInfo[FIRST_DAY_INDEX]
        let indexPath = IndexPath(item: item, section: distanceFromStartComponent.month)
        
        return indexPath
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let dateBeingSelectedByUser = dateBeingSelectedByUser else {
            return
        }
        
        let currentMonthInfo : [Int] = monthInfo[(indexPath as NSIndexPath).section]!
        
        let fromStartOfMonthIndexPath = IndexPath(item: (indexPath as NSIndexPath).item - currentMonthInfo[FIRST_DAY_INDEX], section: (indexPath as NSIndexPath).section)
        
        var timeLogsOnSelectedDate = [TimeLog]()
        
        if let timeLogsOnDate = self.timeLogsByIndexPath[fromStartOfMonthIndexPath] {
            timeLogsOnSelectedDate = timeLogsOnDate
        }
        
        delegate?.calendar(self, didSelectDate: dateBeingSelectedByUser, with: timeLogsOnSelectedDate)
        
        // Update model
        selectedIndexPaths.append(indexPath)
        selectedDates.append(dateBeingSelectedByUser)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        guard let dateBeingSelectedByUser = dateBeingSelectedByUser else {
            return
        }
        
        guard let index = selectedIndexPaths.index(of: indexPath) else {
            return
        }
        
        delegate?.calendar?(self, didDeselectDate: dateBeingSelectedByUser)
        
        selectedIndexPaths.remove(at: index)
        selectedDates.remove(at: index)
        
    }
    
    
    func reloadData() {
        self.calendarView.reloadData()
    }
    
    
    func setDisplayDate(_ date : Date, animated: Bool) {
        
        if let dispDate = self.displayDate {
            
            // skip is we are trying to set the same date
            if  date.compare(dispDate) == ComparisonResult.orderedSame {
                return
            }
            
            
            // check if the date is within range
            if  date.compare(startDateCache) == ComparisonResult.orderedAscending ||
                date.compare(endDateCache) == ComparisonResult.orderedDescending   {
                return
            }
            
            
            let difference = self.gregorian.components([Calendar.monthSymbols], from: startOfMonthCache, to: date, options: Calendar())
            
            let distance : CGFloat = CGFloat(difference.month) * self.calendarView.frame.size.width
            
            self.calendarView.setContentOffset(CGPoint(x: distance, y: 0.0), animated: animated)
        }
    }
}

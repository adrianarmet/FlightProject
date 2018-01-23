//
//  MainViewController.swift
//  FlightProject
//
//  Created by Adrian Armet on 1/22/18.
//  Copyright © 2018 test. All rights reserved.
//

import UIKit
import CVCalendar

protocol CalendarProtocol {
    func getSelectedDate(selectedDate: Date)
}

class CalendarViewController: UIViewController, CVCalendarViewDelegate, CVCalendarMenuViewDelegate {
    func presentationMode() -> CalendarMode {
        return CalendarMode.monthView
    }
    
    func firstWeekday() -> Weekday {
        return Weekday.monday
    }
    
    @IBOutlet weak var menuView: CVCalendarMenuView!
    @IBOutlet weak var calendarView: CVCalendarView!
    
    @IBOutlet weak var labelMonth: UILabel!
    
    var calendarDelegate: CalendarProtocol?
    
    var shouldShowDaysOut = true
    var animationFinished = true
    
    var currentSelectedDate: NSDate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.calendarView.commitCalendarViewUpdate()
        self.menuView.commitMenuViewUpdate()
        
        self.calendarView!.changeDaysOutShowingState(shouldShow: false) // just unhide days out in loaded Month Views
        self.shouldShowDaysOut = false // passing value for 'shouldShowWeekdaysOut:'
        
        if(self.currentSelectedDate != nil) {
            self.calendarView.toggleViewWithDate(self.currentSelectedDate! as Date)
        }
        
        self.disablePreviousDays()
        
        self.labelMonth.text = CVDate(date: NSDate() as Date).globalDescription

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func disablePreviousDays() {
        let calendar = NSCalendar.current
        for weekV in calendarView.contentController.presentedMonthView.weekViews {
            for dayView in weekV.dayViews {
                if calendar.compare(dayView.date.convertedDate()!, to: NSDate() as Date, toGranularity: .day) == .orderedAscending {
                    dayView.isUserInteractionEnabled = false
                    dayView.dayLabel.textColor = calendarView.appearance.dayLabelWeekdayOutTextColor
                }
            }
        }
    }
    
    func shouldShowWeekdaysOut() -> Bool {
        return self.shouldShowDaysOut
    }
    
    func shouldAutoSelectDayOnMonthChange() -> Bool {
        return false
    }
    
    func didSelectDayView(_ dayView: DayView, animationDidFinish: Bool) {
        let components = NSDateComponents()
        components.day = dayView.date!.day
        components.month = dayView.date!.month
        components.year = dayView.date!.year
        let weekdayIndex = dayView.weekdayIndex! - 1
        
        let selectedDate = NSCalendar.current.date(from: components as DateComponents)
        calendarDelegate?.getSelectedDate(selectedDate: selectedDate!)
        
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    func presentedDateUpdated(_ date: CVDate) {
        labelMonth.text = date.globalDescription
    }
    
    func topMarker(shouldDisplayOnDayView dayView: CVCalendarDayView) -> Bool {
        return false
    }
    
    func dotMarker(shouldMoveOnHighlightingOnDayView dayView: CVCalendarDayView) -> Bool {
        return false
    }
    
    func dotMarker(shouldShowOnDayView dayView: CVCalendarDayView) -> Bool {
        return false
    }
    
    func dotMarker(colorOnDayView dayView: CVCalendarDayView) -> UIColor {
        return UIColor.white
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

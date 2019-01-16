//
//  ScheduleMaster.swift
//  Bell View
//
//  Created by Gavin Ryder on 1/14/19.
//  Copyright © 2019 Gavin Ryder. All rights reserved.
//

import UIKit
import Foundation

class ScheduleMaster {
    private var defaultScheduleForToday:String = ""
    private var doesCurrentDayHaveSpecialSchedule:Bool = false
    
    enum weekDay: Int, Decodable {
        case sunday = 1
        case monday = 2
        case tuesday = 3
        case wedensday = 4
        case thursday = 5
        case friday = 6
        case saturday = 7
    }
    
    //The actual DataStucture containing the Default Schedule
    //for the various days of the week.
    struct DefaultDay: Decodable {
        let scheduleType: String
        let dayOfWeek: weekDay
    }
    
    struct SpecialDay: Decodable {
        let scheduleType: String
        let beginDate: Date
        let endDate: Date?
        let desc: String?
    }
    
    struct BellTime: Decodable {
        let desc: String
        let timeInterval: TimeInterval
    }
    
    typealias AllSpecialDays = [SpecialDay]
    
    var allSpecialDays: AllSpecialDays?
    
    typealias BellSchedules = [Schedule]
    
    var allSchedules: BellSchedules?
    
    typealias AllDefaultDays = [DefaultDay]
    
    var allDefaultDays: AllDefaultDays?
    
    
    //This is the Struct that holds all the belltimes
    struct Schedule: Decodable {
        var scheduleType: String
        let bellTimes: [BellTime]
    }
    
    
    init (mainBundle: Bundle) {
        //Parser for Special Days
        let plistURLSpecialDays: URL = mainBundle.url(forResource:"specialDays", withExtension:"plist")!
        
        if let data = try? Data(contentsOf: plistURLSpecialDays) {
            let decoder = PropertyListDecoder()
            allSpecialDays = try! decoder.decode(AllSpecialDays.self, from:data)
        }
        
        for specialDay in allSpecialDays! {
            //print ("Found A Special Day on: \(specialDay.beginDate)")
            
            if specialDay.endDate != nil {
               // print ("+++End Date:\(specialDay.endDate!)")
            }
            if specialDay.desc != nil {
               // print ("---Description:\(specialDay.desc!)")
            }
        }
        //*****************************************************
        
        //Bell Schedule Parser
        
        //let mainBundle: Bundle = Bundle.main
        let pListURLBellSchedules: URL = mainBundle.url(forResource:"Schedules", withExtension:"plist")!
        
        if let data = try? Data(contentsOf: pListURLBellSchedules) {
            let decoder = PropertyListDecoder()
            allSchedules = try! decoder.decode(BellSchedules.self, from:data)
        }
        
        for schedule in allSchedules! {
            //print ("I know a schedule with the type:\(schedule.scheduleType)")
        }
        
//        print ("")
//        print ("Normal schedule has these periods:")
        
        let normalSchedule: Schedule = allSchedules![0]
        
        let ringTimeBase = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: Date())!
        
        for bellTime in normalSchedule.bellTimes {
            let periodDescription = bellTime.desc
            let ringAdjust: TimeInterval = bellTime.timeInterval
            let periodRingTime:Date = ringTimeBase + ringAdjust
            
            //print ("\(periodDescription) Rings at:\(periodRingTime)")
        }
        
        //******************************************************
        
        //Default Schedule Parser
        
        //let mainBundle: Bundle = Bundle.main
        let plistURLDefaultDays: URL = mainBundle.url(forResource:"defaultSchedule", withExtension:"plist")!
        
        if let data = try? Data(contentsOf: plistURLDefaultDays) {
            let decoder = PropertyListDecoder()
            allDefaultDays = try! decoder.decode(AllDefaultDays.self, from:data)
        }
        
        let today = Calendar.current.component(.weekday, from:Date())
        
        for defaultDay in allDefaultDays! {
            if defaultDay.dayOfWeek.rawValue == today {
                defaultScheduleForToday = defaultDay.scheduleType
                //print ("Today's Schedule Type Is: \(defaultDay.scheduleType)")
            }
        }

    }
    
    public func getScheduleType() -> String {
        var theSpecialDay: SpecialDay?
        for canidateSpecialDay in allSpecialDays!{ //hack: pull the day and month and compare them seperately
            if self.isDateWithininSpecialDay(specialDay: canidateSpecialDay) {
                theSpecialDay = canidateSpecialDay
            }
        }

        if (theSpecialDay == nil){
            print(defaultScheduleForToday)
            return defaultScheduleForToday
        } else {
            print((theSpecialDay?.scheduleType)!)
            return (theSpecialDay?.scheduleType)!
        }
        
    }
    
    public func getNextBellDate() -> Date {
        return Date();
    }
    
    public func getCurrentBellTimeDescription() -> String { //get the current bellTime object and pull the description from it
        var i = 0;
        var x = 0;
        var currentTime = Date()
        currentTime = Calendar.current.date(bySettingHour: 9, minute: 30, second: 0, of: Date())!
        var scheduleHolder: Schedule
            while i<(allSchedules?.count)! {
                scheduleHolder = allSchedules![i]
                scheduleHolder.scheduleType = getScheduleType()
                while x < scheduleHolder.bellTimes.count-1 {
                    //print (convertDateToTimeInterval(myDate: currentTime))
                    if convertDateToTimeInterval(myDate: currentTime) >= scheduleHolder.bellTimes[x].timeInterval && convertDateToTimeInterval(myDate: currentTime) < scheduleHolder.bellTimes[x+1].timeInterval {
                        print(scheduleHolder.bellTimes[x].desc)
                        return scheduleHolder.bellTimes[x].desc
                    }
                    x = x + 1;
                }
                i = i+1
        }
        print ("Free")
        return "Free"
    }
    
    public func getNextBellTimeDescription() -> String {
        return "String";
    }
    

    
    public func timerUntilNextEvent() -> Timer {
        return Timer();
    }
    
    //*************************************
    
    private func getCurrentBellSchedule() -> Schedule {
        let bellTime:BellTime = BellTime(desc: "blank", timeInterval: 2300) //just to satisfy method return --REMOVE--
        
        let emptySchedule: Schedule = Schedule(scheduleType: "Blank", bellTimes: [bellTime,bellTime])
        return emptySchedule
        
        //return Schedule("blank", "Period null", Date());
    }
    
//    private func getNextBellTime() -> BellTime { //given the current time and schedule type, return the next bell time object
//
//    }
//
//    private func getCurrentBellTime() -> BellTime { //given the current time and schedule type, return the current bell time object
//        var b:BellTime
//        return b;
//    }
    
    func isDateWithininSpecialDay (specialDay: SpecialDay) -> Bool {
        var now = Date() //Create date set to midnight on this date
        now = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: Date())!
        var beginDate:Date  = specialDay.beginDate
        beginDate = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: beginDate)!
        var endDate: Date? = specialDay.endDate
        if endDate != nil {
            endDate = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: endDate!)!
        }
        var inRange:Bool = false
        
        if now == beginDate {
            inRange = true
        }
        
        if endDate != nil {
            if now == endDate {
                inRange = true
            } else if now > beginDate && now < endDate! {
                inRange = true
            }
        }
        
        return inRange
    }
    
    func convertDateToTimeInterval (myDate:Date) -> TimeInterval{ //TODO: Pass date object as a param
        let calendar = Calendar.current
        let hourToSec = calendar.component(.hour, from: myDate)*3600;
        let minToSec = calendar.component(.minute, from: myDate)*60;
        return Double(minToSec + hourToSec)
    }
    
}

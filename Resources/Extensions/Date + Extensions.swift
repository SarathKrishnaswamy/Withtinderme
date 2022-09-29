//
//  Date + Extensions.swift
//  Spark
//
//  Created by Gowthaman P on 25/07/21.
//

import UIKit

//extension Date {
//    func timeAgoDisplay() -> String {
//        let formatter = RelativeDateTimeFormatter()
//        formatter.unitsStyle = .abbreviated
//        return formatter.localizedString(for: self, relativeTo: Date())
//    }
//}

/// Set all the date contents with timestamp to be converted as string 
extension Date {
    func timeAgo(timeStamp:String) -> String {
        
        let calendar = Calendar.current
        let minuteAgo = calendar.date(byAdding: .minute, value: -1, to: Date())!
        let hourAgo = calendar.date(byAdding: .hour, value: -1, to: Date())!
        let dayAgo = calendar.date(byAdding: .day, value: -1, to: Date())!
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date())!
        
        if minuteAgo < self {
            let diff = Calendar.current.dateComponents([.second], from: self, to: Date()).second ?? 0
            return "\(diff) s"
        } else if hourAgo < self {
            let diff = Calendar.current.dateComponents([.minute], from: self, to: Date()).minute ?? 0
            if diff == 1 {
                return "\(diff) m"
            }
            return "\(diff) m"
        } else if dayAgo < self {
            let diff = Calendar.current.dateComponents([.hour], from: self, to: Date()).hour ?? 0
            if diff == 1 {
                return "\(diff) h"
            }
            return "\(diff) h"
        } else if weekAgo < self {
            let diff = Calendar.current.dateComponents([.day], from: self, to: Date()).day ?? 0
            if diff == 1 {
                return "\(diff) d"
            }
            
            if diff > 30 {
                
                
                return "\(diff) d"
            }
            return "\(diff) d"
        }
        
        //        return ""
        let diff = Calendar.current.dateComponents([.weekOfYear], from: self, to: Date()).weekOfYear ?? 0
        if diff == 1 {
            let timeinterval : TimeInterval = (timeStamp as NSString).doubleValue
            let dateFromServer = NSDate(timeIntervalSince1970:timeinterval)
            let dateFormater : DateFormatter = DateFormatter()
            dateFormater.dateFormat = "dd MMM, yyyy"
            print(dateFormater.string(from: dateFromServer as Date))
            
            return "\(diff) w"
        }
        let timeinterval : TimeInterval = (timeStamp as NSString).doubleValue
        let dateFromServer = NSDate(timeIntervalSince1970:timeinterval)
        let dateFormater : DateFormatter = DateFormatter()
        dateFormater.dateFormat = "dd MMM, yyyy"
        print(dateFormater.string(from: dateFromServer as Date))
        return "\(dateFormater.string(from: dateFromServer as Date))"
    }
    
    
    func convertTimeStampToDOBWithTime(timeStamp:String) -> String {
            let timeinterval : TimeInterval = (timeStamp as NSString).doubleValue
            let dateFromServer = NSDate(timeIntervalSince1970:timeinterval)
            let dateFormater : DateFormatter = DateFormatter()
            dateFormater.dateFormat = "dd MMM, yyyy"
            return dateFormater.string(from: dateFromServer as Date)
        }
    
    
    
    func timeAgoDisplays(timeStamp:String) -> String {
        
        let calendar = Calendar.current
        let dayAgo = calendar.date(byAdding: .day, value: -1, to: Date())!
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date())!
        
        if dayAgo < self {
            let timeinterval : TimeInterval = (timeStamp as NSString).doubleValue
            let dateFromServer = NSDate(timeIntervalSince1970:timeinterval)
            let dateFormater : DateFormatter = DateFormatter()
            dateFormater.dateFormat = "hh:mm a"
            return dateFormater.string(from: dateFromServer as Date)
            
        } else if weekAgo < self {
            let diff = Calendar.current.dateComponents([.day], from: self, to: Date()).day ?? 0
            if diff == 1 {
                return "\(diff)d"
            }
            return "\(diff)d"
        }
        let diff = Calendar.current.dateComponents([.weekOfYear], from: self, to: Date()).weekOfYear ?? 0
        if diff == 1 {
            return "\(diff)w"
        }
        return "\(diff)w"
    }
    
}

extension Date {
    
    func timeAgoSinceDate() -> String {
        
        // From Time
        let fromDate = self
        
        // To Time
        let toDate = Date()
        
        // Estimation
        // Year
        //        if let interval = Calendar.current.dateComponents([.year], from: fromDate, to: toDate).year, interval > 0  {
        //
        //            return interval == 1 ? "\(interval)" + " " + "y" : "\(interval)" + " " + "y"
        //        }
        
        // Month
        //        if let interval = Calendar.current.dateComponents([.month], from: fromDate, to: toDate).month, interval > 0  {
        //
        //            return interval == 1 ? "\(interval)" + " " + "month ago" : "\(interval)" + " " + "months ago"
        //        }
        
        // Day
        if let interval = Calendar.current.dateComponents([.day], from: fromDate, to: toDate).day, interval > 0  {
            
            if interval > 6 {
                let timeStamp = fromDate.timeIntervalSince1970
                let timeinterval : TimeInterval = timeStamp
                let dateFromServer = NSDate(timeIntervalSince1970:timeinterval)
                let dateFormater : DateFormatter = DateFormatter()
                dateFormater.dateFormat = "dd MMM, yyyy"
                return dateFormater.string(from: dateFromServer as Date)
                //return interval == 1 ? "\(interval)" + " " + "d" : "\(interval)" + " " + "d"
            }
            return interval == 1 ? "\(interval)" + " " + "d" : "\(interval)" + " " + "d"
        }
        
        // Hours
        if let interval = Calendar.current.dateComponents([.hour], from: fromDate, to: toDate).hour, interval > 0 {
            
            return interval == 1 ? "\(interval)" + " " + "h" : "\(interval)" + " " + "h"
        }
        
        // Minute
        if let interval = Calendar.current.dateComponents([.minute], from: fromDate, to: toDate).minute, interval > 0 {
            
            return interval == 1 ? "\(interval)" + " " + "m" : "\(interval)" + " " + "m"
        }
        
        return "few moments ago"
    }
    
    ///Chat detail page sender/receiver date
    
    
    
    
    
    
    func timeAgoForSenderReceiverMeaages() -> String {
        
        // From Time
        let fromDate = self
        
        // To Time
        let toDate = Date()
        
        // Estimation
        // Year
        //        if let interval = Calendar.current.dateComponents([.year], from: fromDate, to: toDate).year, interval > 0  {
        //
        //            return interval == 1 ? "\(interval)" + " " + "y" : "\(interval)" + " " + "y"
        //        }
        
        // Month
        //        if let interval = Calendar.current.dateComponents([.month], from: fromDate, to: toDate).month, interval > 0  {
        //
        //            return interval == 1 ? "\(interval)" + " " + "month ago" : "\(interval)" + " " + "months ago"
        //        }
        
        // Day
        if let interval = Calendar.current.dateComponents([.day], from: fromDate, to: toDate).day, interval > 0  {
            if interval < 2 {
                let timeinterval : TimeInterval = fromDate.timeIntervalSince1970
                let dateFromServer = NSDate(timeIntervalSince1970:timeinterval)
                let dateFormater : DateFormatter = DateFormatter()
                dateFormater.dateFormat = "hh:mm a"
                return dateFormater.string(from: dateFromServer as Date)
            }
            if interval > 30 {
                let timeStamp = fromDate.timeIntervalSince1970
                let timeinterval : TimeInterval = timeStamp
                let dateFromServer = NSDate(timeIntervalSince1970:timeinterval)
                let dateFormater : DateFormatter = DateFormatter()
                dateFormater.dateFormat = "MMM dd,yyyy"
                return dateFormater.string(from: dateFromServer as Date)
                //return interval == 1 ? "\(interval)" + " " + "d" : "\(interval)" + " " + "d"
            }
            return interval == 1 ? "\(interval)" + " " + "d" : "\(interval)" + " " + "d"
        }
        
        // Hours
        if let interval = Calendar.current.dateComponents([.hour], from: fromDate, to: toDate).hour, interval > 0 {
            
            return interval == 1 ? "\(interval)" + " " + "h" : "\(interval)" + " " + "h"
        }
        
        // Minute
        if let interval = Calendar.current.dateComponents([.minute], from: fromDate, to: toDate).minute, interval > 0 {
            
            return interval == 1 ? "\(interval)" + " " + "m" : "\(interval)" + " " + "m"
        }
        
        return "few moments ago"
    }
}



extension Date {
    
    
    func timeAgoDisplay(DateString:String) -> String {
        
        let secondsAgo = Double(Date().timeIntervalSince(self))
        
        let minute = 60.0
        let hour = 60.0 * minute
        let day = 24.0 * hour
        let week = 7.0 * day
        
        var phrase = String()
        let month = 4.0 * week
        
        let quotient: Double
        let unit: String
        if secondsAgo < minute {
            quotient = secondsAgo
            unit = "s"
            let QuoInt = Int(round(quotient))//Int(quotient.rounded(digits: 1))
            print(QuoInt)
            phrase = "\(QuoInt) \(unit)\(QuoInt == 1 ? "" : "")"
        } else if secondsAgo < hour {
            quotient = secondsAgo / minute
            unit = "m"
            let QuoInt = Int(round(quotient))//Int(quotient.rounded(digits: 1))
            print(QuoInt)
            phrase = "\(QuoInt) \(unit)\(QuoInt == 1 ? "" : "")"
            
        } else if secondsAgo < day {
            quotient = secondsAgo / hour
            unit = "h"
            let QuoInt = Int(round(quotient))//Int(quotient.rounded(digits: 1))
            print(QuoInt)
            phrase = "\(QuoInt) \(unit)\(QuoInt == 1 ? "" : "")"
        } else if secondsAgo < week {
            quotient = secondsAgo / day
            unit = "d"
            let QuoInt = Int(round(quotient))//Int(quotient.rounded(digits: 1))
            print(QuoInt)
            phrase = "\(QuoInt) \(unit)\(QuoInt == 1 ? "" : "")"
        }
        else if secondsAgo < month {
            quotient = secondsAgo / week
            unit = "w"
            let QuoInt = Int(round(quotient))//Int(quotient.rounded(digits: 1))
            print(QuoInt)
            phrase = "\(QuoInt) \(unit)\(QuoInt == 1 ? "" : "")"
            
        }
//                else if Int(day) > 7{
//                    phrase =
//                }
//
//                else {
//                    quotient = secondsAgo / month
//                    unit = "m"
//                }
        
        // let quoround = quotient.rounded(.towardZero)
        // print(quoround)
        
        
        return phrase
    }
}


extension Double {
    func rounded(digits: Int) -> Double {
        let multiplier = pow(10.0, Double(digits))
        return (self * multiplier).rounded() / multiplier
    }
}

extension String{
    func timestampToStringAgo(timestamp: Int64) -> String{
        let actualTime = Int64(Date().timeIntervalSince1970*1000)
        var lastSeenTime = actualTime - timestamp
        lastSeenTime /= 1000 //seconds
        var lastTimeString = ""
        if lastSeenTime < 60 {
            if lastSeenTime == 1 {
                lastTimeString = String(lastSeenTime) + " second ago"
            } else {
                lastTimeString = String(lastSeenTime) + " seconds ago"
            }
        } else {
            lastSeenTime /= 60
            if lastSeenTime < 60 {
                if lastSeenTime == 1 {
                    lastTimeString =  String(lastSeenTime) + " minute ago"
                } else {
                    lastTimeString =  String(lastSeenTime) + " minutes ago"
                }
                
            } else {
                lastSeenTime /= 60
                if lastSeenTime < 24 {
                    if lastSeenTime == 1 {
                        lastTimeString = String(lastSeenTime) + " hour ago"
                    } else {
                        lastTimeString = String(lastSeenTime) + " hours ago"
                    }
                } else {
                    lastSeenTime /= 24
                    if lastSeenTime == 1 {
                        lastTimeString = String(lastSeenTime) + " day ago"
                    } else {
                        lastTimeString = String(lastSeenTime) + " days ago"
                    }
                }
            }
        }
        return lastTimeString
    }
}

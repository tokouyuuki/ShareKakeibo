//
//  DateModel.swift
//  Kakeibo
//
//  Created by 山口誠士 on 2021/11/20.
//
import Foundation

class DateModel{
    
    var today = Int()
    var month = Int()
    var year = Int()
    
    
    func getPeriodOfTextField(settelemtDay: Int,completion:(Date,Date) -> ()){
        
        getThisDete()
        
        var minimumDate = Date()
        var maximumDate = Date()
        var minDateStr = String()
        var maxDateStr = String()
        if today < settelemtDay{
            maxDateStr = "\(year)年\(month)月\(settelemtDay)日"
            if month == 1{
                minDateStr = "\(year - 1)年12月\(settelemtDay)日"
            }else{
                minDateStr = "\(year)年\(month - 1)月\(settelemtDay - 1)日"
            }
            maximumDate = changeDate(dateString: maxDateStr)
            minimumDate = changeDate(dateString: minDateStr)
            completion(maximumDate,minimumDate)
        }else if today >= settelemtDay{
            minDateStr = "\(year)年\(month)月\(settelemtDay)日"
            if month == 12{
                maxDateStr = "\(year + 1)年1月\(settelemtDay - 1)日"
            }else{
                maxDateStr = "\(year)年\(month + 1)月\(settelemtDay - 1)日"
            }
            maximumDate = changeDate(dateString: maxDateStr)
            minimumDate = changeDate(dateString: minDateStr)
            completion(maximumDate,minimumDate)
        }
    }
    
    func getPeriodOfThisMonth(settelemtDay: Int,completion:(Date,Date) -> ()){
        
        getThisDete()
        
        var minimumDate = Date()
        var maximumDate = Date()
        var minDateStr = String()
        var maxDateStr = String()
        if today < settelemtDay{
            maxDateStr = "\(year)年\(month)月\(settelemtDay)日"
            if month == 1{
                minDateStr = "\(year - 1)年12月\(settelemtDay)日"
            }else{
                minDateStr = "\(year)年\(month - 1)月\(settelemtDay)日"
            }
            maximumDate = changeDate(dateString: maxDateStr)
            minimumDate = changeDate(dateString: minDateStr)
            completion(maximumDate,minimumDate)
        }else if today >= settelemtDay{
            minDateStr = "\(year)年\(month)月\(settelemtDay)日"
            if month == 12{
                maxDateStr = "\(year + 1)年1月\(settelemtDay)日"
            }else{
                maxDateStr = "\(year)年\(month + 1)月\(settelemtDay)日"
            }
            maximumDate = changeDate(dateString: maxDateStr)
            minimumDate = changeDate(dateString: minDateStr)
            completion(maximumDate,minimumDate)
        }
    }
    
    func getPeriodOfLastMonth(settelemtDay: Int,completion:(Date,Date) -> ()){
        
        getThisDete()
        
        var minimumDate = Date()
        var maximumDate = Date()
        var minDateStr = String()
        var maxDateStr = String()
        if today < settelemtDay{
            if month == 2{
                minDateStr = "\(year - 1)年12月\(settelemtDay)日"
                maxDateStr = "\(year)年01月\(settelemtDay)日"
            }else if month == 1{
                minDateStr = "\(year - 1)年11月\(settelemtDay)日"
                maxDateStr = "\(year - 1)年12月\(settelemtDay)日"
            }else{
                minDateStr = "\(year)年\(month - 2)月\(settelemtDay)日"
                maxDateStr = "\(year)年\(month - 1)月\(settelemtDay)日"
            }
            maximumDate = changeDate(dateString: maxDateStr)
            minimumDate = changeDate(dateString: minDateStr)
            completion(maximumDate,minimumDate)
        }else if today >= settelemtDay{
            if month == 1{
                minDateStr = "\(year - 1)年12月\(settelemtDay)日"
                maxDateStr = "\(year)年\(month)月\(settelemtDay)日"
            }else{
                minDateStr = "\(year)年\(month - 1)月\(settelemtDay)日"
                maxDateStr = "\(year)年\(month)月\(settelemtDay)日"
            }
            maximumDate = changeDate(dateString: maxDateStr)
            minimumDate = changeDate(dateString: minDateStr)
            completion(maximumDate,minimumDate)
        }
    }
    
    func getThisDete(){
        let calendar = Calendar(identifier: .gregorian)
        let date = calendar.dateComponents([.year,.month,.day], from: Date())
        today = date.day!
        year = date.year!
        month = date.month!
    }
    
    func changeDate(dateString:String) -> Date{
        var date = Date()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy年MM月dd日"
        dateFormatter.locale = Locale(identifier: "ja_JP")
        dateFormatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
        
        date = dateFormatter.date(from: dateString)!
        
        return date
    }
    
    func changeString(date:Date) -> String{

        var string = String()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy年MM月dd日"
        dateFormatter.locale = Locale(identifier: "ja_JP")
        dateFormatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
        
        string = dateFormatter.string(from: date)
        
        return string
    }

    
}

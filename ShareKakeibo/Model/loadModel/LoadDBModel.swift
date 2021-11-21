//
//  LoadDBModel.swift
//  Kakeibo
//
//  Created by 都甲裕希 on 2021/10/24.
//
import Foundation
import Firebase
import FirebaseFirestore

@objc protocol LoadOKDelegate {
    @objc optional func loadUserInfo_OK(userName:String,profileImage:String,email:String,password:String)
    @objc optional func loadUserSearch_OK()
    @objc optional func loadJoinGroup_OK()
    @objc optional func loadNotJoinGroup_OK(groupIDArray:[String],notJoinCount:Int)
    @objc optional func loadGroupName_OK(groupName:String,groupImage:String)
    @objc optional func loadSettlementNotification_OK()
    @objc optional func loadSettlementDay_OK(settlementDay:String)
    @objc optional func loadUserIDAndSettlementDic_OK(settlementDic:Dictionary<String,Bool>,userIDArray:[String])
    @objc optional func loadGroupMember_OK()
    @objc optional func loadMonthDetails_OK()
    @objc optional func loadCategoryGraphOfTithMonth_OK(categoryDic:Dictionary<String,Int>)
    @objc optional func loadMonthlyTransition_OK(countArray:[Int])
    @objc optional func loadMonthPayment_OK(groupPaymentOfMonth:Int,paymentAverageOfMonth:Int,userIDArray:[String])
    @objc optional func loadMonthSettlement_OK()
}

class LoadDBModel{
    
    var loadOKDelegate:LoadOKDelegate?
    var db = Firestore.firestore()
    var groupSets:[GroupSets] = []
    var userSearchSets = [UserSearchSets]()
    var notificationSets = [NotificationSets]()
    var monthMyDetailsSets = [MonthMyDetailsSets]()
    var monthGroupDetailsSets = [MonthGroupDetailsSets]()
    var settlementSets = [SettlementSets]()
    let dateFormatter = DateFormatter()
    var countArray = [Int]()
    
    
    //userの情報を取得するメソッド
    func loadUserInfo(userID:String,activityIndicatorView:UIActivityIndicatorView){
        db.collection("userManagement").document(userID).addSnapshotListener { (snapShot, error) in
            
            if error != nil{
                activityIndicatorView.stopAnimating()
                return
            }
            let data = snapShot?.data()
            if let userName = data!["userName"] as? String,let profileImage = data!["profileImage"] as? String,let email = data!["email"] as? String,let password = data!["password"] as? String{
                self.loadOKDelegate?.loadUserInfo_OK?(userName: userName, profileImage: profileImage, email: email, password: password)
            }
            activityIndicatorView.stopAnimating()
        }
    }
    
    //メールアドレスで検索するメソッド。メールアドレスと一致するユーザー情報を取得。
    func loadUserSearch(email:String,activityIndicatorView:UIActivityIndicatorView){
        db.collection("userManagement").whereField("email", isEqualTo: email).addSnapshotListener { (snapShot, error) in
            
            self.userSearchSets = []
            if error != nil{
                activityIndicatorView.stopAnimating()
                return
            }
            if let snapShotDoc = snapShot?.documents{
                for doc in snapShotDoc{
                    let data = doc.data()
                    let userName = data["userName"] as! String
                    let profileImage = data["profileImage"] as! String
                    let userID = data["userID"] as! String
                    let newData = UserSearchSets(userName: userName, profileImage: profileImage, userID: userID)
                    self.userSearchSets.append(newData)
                }
            }
            self.loadOKDelegate?.loadUserSearch_OK?()
        }
    }
    
    //参加しているグループの情報を取得するロード
    func loadJoinGroup(groupID:String,userID:String){
        db.collection("groupManagement").whereField("userIDArray", arrayContains: userID).order(by: "create_at").addSnapshotListener { (snapShot, error) in
            self.groupSets = []
            if error != nil{
                print(error.debugDescription)
                return
            }
            if let snapShotDoc = snapShot?.documents{
                for doc in snapShotDoc{
                    let data = doc.data()
                    let groupName = data["groupName"] as! String
                    let groupImage = data["groupImage"] as! String
                    let groupID = data["groupID"] as! String
                    let newData = GroupSets(groupName: groupName, groupImage: groupImage, groupID: groupID, create_at: nil)
                    self.groupSets.append(newData)
                }
            }
            self.groupSets.reverse()
            self.loadOKDelegate?.loadJoinGroup_OK?()
        }
    }
    
    //招待されているグループの数を取得するロード
    func loadNotJoinGroup(userID:String){
        db.collection("userManagement").document(userID).addSnapshotListener { (snapShot, error) in
            
            var groupIDArray = [String]()
            var notJoinCount = 0
            if error != nil{
                return
            }
            if let data = snapShot?.data(){
                if let joinGroupDic = data["joinGroupDic"] as? Dictionary<String,Bool>{
                    for (key,value) in joinGroupDic{
                        if value == false{
                            groupIDArray.append(key)
                            notJoinCount = notJoinCount + 1
                        }
                    }
                }
            }
            self.loadOKDelegate?.loadNotJoinGroup_OK?(groupIDArray: groupIDArray, notJoinCount: notJoinCount)
        }
    }
    
    //招待されているグループの情報を取得するロード
    func loadNotJoinGroupInfo(groupIDArray:[String],completion:@escaping(GroupSets)->()){
        for groupID in groupIDArray{
            db.collection("groupManagement").document(groupID).addSnapshotListener { (sanpShot, error) in
                
                if error != nil{
                    return
                }
                if let data = sanpShot?.data(){
                    let groupName = data["groupName"] as! String
                    let groupImage = data["groupImage"] as! String
                    let groupID = data["groupID"] as! String
                    let create_at = data["create_at"] as! Double
                    let newData = GroupSets(groupName: groupName, groupImage: groupImage, groupID: groupID, create_at: create_at)
                    completion(newData)
                }
            }
        }
        
    }
    
    //グループ名、グループ画像を取得するロード。
    func loadGroupName(groupID:String,activityIndicatorView:UIActivityIndicatorView){
        db.collection("groupManagement").document(groupID).addSnapshotListener { (snapShot, error) in
            
            if error != nil{
                activityIndicatorView.stopAnimating()
                return
            }
            if let data = snapShot?.data(){
                let groupName = data["groupName"] as! String
                let groupImage = data["groupImage"] as! String
                self.loadOKDelegate?.loadGroupName_OK?(groupName: groupName, groupImage: groupImage)
            }
        }
    }
    
    //決済日を取得し決済通知するロード
    func loadSettlementNotification(userID:String,day:String,activityIndicatorView:UIActivityIndicatorView){
        db.collection("groupManagement").whereField("userIDArray", arrayContains: userID).addSnapshotListener { (snapShot, error) in
            
            self.notificationSets = []
            if error != nil{
                activityIndicatorView.stopAnimating()
                return
            }
            if let snapShotDoc = snapShot?.documents{
                for doc in snapShotDoc{
                    let data = doc.data()
                    let settlementDay = data["settlementDay"] as! String
                    let groupName = data["groupName"] as! String
                    let groupID = data["groupID"] as! String
                    if settlementDay == day{
                        let newData = NotificationSets(groupName: groupName, groupID: groupID)
                        self.notificationSets.append(newData)
                    }
                }
            }
            self.loadOKDelegate?.loadSettlementNotification_OK?()
        }
    }
    
    //決済日を取得するロード
    func loadSettlementDay(groupID:String,activityIndicatorView:UIActivityIndicatorView){
        db.collection("groupManagement").document(groupID).getDocument { (snapShot, error) in
            
            if error != nil{
                activityIndicatorView.stopAnimating()
                return
            }
            if let data = snapShot?.data(){
                let settlementDay = data["settlementDay"] as! String
                self.loadOKDelegate?.loadSettlementDay_OK?(settlementDay: settlementDay)
            }
            activityIndicatorView.stopAnimating()
        }
    }
    
    //グループに所属する人のuserIDと決済可否を取得するロード
    func loadUserIDAndSettlementDic(groupID:String,activityIndicatorView:UIActivityIndicatorView){
        db.collection("groupManagement").document(groupID).addSnapshotListener { (snapShot, error) in
            
            if error != nil{
                activityIndicatorView.stopAnimating()
                return
            }
            if let data = snapShot?.data(){
                let settlementDic = data["settlementDic"] as! Dictionary<String,Bool>
                let userIDArray = data["userIDArray"] as! Array<String>
                self.loadOKDelegate?.loadUserIDAndSettlementDic_OK?(settlementDic: settlementDic, userIDArray: userIDArray)
            }
            activityIndicatorView.stopAnimating()
        }
    }
    
    //グループに所属する人の名前とプロフィール画像を取得するロード
    func loadGroupMember(userIDArray:[String],completion:@escaping(UserSets)->()){
        var count = 0
        for userID in userIDArray{
            
            db.collection("userManagement").document(userID).addSnapshotListener { (snapShot, error) in
                count += 1
                if error != nil{
                    return
                }
                if let data = snapShot?.data(){
                    let profileImage = data["profileImage"] as! String
                    let userName = data["userName"] as! String
                    let newData = UserSets(profileImage: profileImage, userName: userName, userID: userID)
                    completion(newData)
                }
                if count == userIDArray.count{
                    self.loadOKDelegate?.loadGroupMember_OK?()
                }
            }
        }
    }
    
    //全体の明細のロード(月分)
    //自分の明細のロード(月分)
    func loadMonthDetails(groupID:String,startDate:Date,endDate:Date,userID:String?,activityIndicatorView:UIActivityIndicatorView){
        self.dateFormatter.dateFormat = "yyyy/MM/dd"
        self.dateFormatter.locale = Locale(identifier: "ja_JP")
        self.dateFormatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
        if userID == nil{
            //全体の明細のロード(月分)
            db.collection("paymentData").whereField("groupID", isEqualTo: groupID).whereField("paymentDay", isGreaterThanOrEqualTo: startDate).whereField("paymentDay", isLessThan: endDate).order(by: "paymentDay").getDocuments { (snapShot, error) in
                
                self.monthGroupDetailsSets = []
                if error != nil{
                    activityIndicatorView.stopAnimating()
                    return
                }
                if let snapShotDoc = snapShot?.documents{
                    for doc in snapShotDoc{
                        let data = doc.data()
                        let productName = data["productName"] as! String
                        let paymentAmount = data["paymentAmount"] as! Int
                        let timestamp = data["paymentDay"] as! Timestamp
                        let category = data["category"] as! String
                        let userID = data["userID"] as! String
                        let date = timestamp.dateValue()
                        let paymentDay = self.dateFormatter.string(from: date)
                        let groupNewData = MonthGroupDetailsSets(productName: productName, paymentAmount: paymentAmount, paymentDay: paymentDay, category: category, userID: userID)
                        self.monthGroupDetailsSets.append(groupNewData)
                    }
                }
                self.loadOKDelegate?.loadMonthDetails_OK?()
            }
        }else if userID != nil{
            //自分の明細のロード(月分)
            db.collection("paymentData").whereField("groupID", isEqualTo: groupID).whereField("userID", isEqualTo: userID!).whereField("paymentDay", isGreaterThanOrEqualTo: startDate).whereField("paymentDay", isLessThan: endDate).order(by: "paymentDay").addSnapshotListener { (snapShot, error) in
                
                self.monthMyDetailsSets = []
                if error != nil{
                    activityIndicatorView.stopAnimating()
                    return
                }
                if let snapShotDoc = snapShot?.documents{
                    for doc in snapShotDoc{
                        let data = doc.data()
                        let documentID = doc.documentID
                        let productName = data["productName"] as! String
                        let paymentAmount = data["paymentAmount"] as! Int
                        let timestamp = data["paymentDay"] as! Timestamp
                        let category = data["category"] as! String
                        let userID = data["userID"] as! String
                        let date = timestamp.dateValue()
                        let paymentDay = self.dateFormatter.string(from: date)
                        let myNewData = MonthMyDetailsSets(productName: productName, paymentAmount: paymentAmount, paymentDay: paymentDay, category: category, userID: userID, documentID: documentID)
                        self.monthMyDetailsSets.append(myNewData)
                    }
                }
                self.loadOKDelegate?.loadMonthDetails_OK?()
            }
        }
    }
    
    //カテゴリ別の合計金額金額
    func loadCategoryGraphOfTithMonth(groupID:String,startDate:Date,endDate:Date,activityIndicatorView:UIActivityIndicatorView){
        
        db.collection("paymentData").whereField("groupID", isEqualTo: groupID).whereField("paymentDay", isGreaterThanOrEqualTo: startDate).whereField("paymentDay", isLessThan: endDate).addSnapshotListener { (snapShot, error) in
            
            var foodCount = 0
            var waterCount = 0
            var electricityCount = 0
            var gasCount = 0
            var communicationCount = 0
            var rentCount = 0
            var othersCount = 0
            
            var categoryDic = [String:Int]()
            
            if error != nil{
                activityIndicatorView.stopAnimating()
                return
            }
            
            if let snapShotDoc = snapShot?.documents{
                for doc in snapShotDoc{
                    let data = doc.data()
                    let category = data["category"] as! String
                    let paymentAmount = data["paymentAmount"] as! Int
                    switch category {
                    case "食費":
                        foodCount = foodCount + paymentAmount
                        categoryDic.updateValue(foodCount, forKey: "食費")
                    case "水道代":
                        waterCount = waterCount + paymentAmount
                        categoryDic.updateValue(waterCount, forKey: "水道代")
                    case "電気代":
                        electricityCount = electricityCount + paymentAmount
                        categoryDic.updateValue(electricityCount, forKey: "電気代")
                    case "ガス代":
                        gasCount = gasCount + paymentAmount
                        categoryDic.updateValue(gasCount, forKey: "ガス代")
                    case "通信費":
                        communicationCount = communicationCount + paymentAmount
                        categoryDic.updateValue(communicationCount, forKey: "通信費")
                    case "家賃":
                        rentCount = rentCount + paymentAmount
                        categoryDic.updateValue(rentCount, forKey: "家賃")
                    case "その他":
                        othersCount = othersCount + paymentAmount
                        categoryDic.updateValue(othersCount, forKey: "その他")
                    default:
                        break
                    }
                }
                
                for (key,value) in categoryDic{
                    if value == 0{
                        categoryDic.removeValue(forKey: key)
                    }
                }
            }
            self.loadOKDelegate?.loadCategoryGraphOfTithMonth_OK?(categoryDic: categoryDic)
        }
    }
    
    
    //1〜12月の全体の推移
    func loadMonthlyAllTransition(groupID:String,year:String,settlementDay:String,startDate:Date,endDate:Date,activityIndicatorView:UIActivityIndicatorView){
        
        db.collection("paymentData").whereField("groupID", isEqualTo: groupID).whereField("paymentDay", isGreaterThanOrEqualTo: startDate).whereField("paymentDay", isLessThan: endDate).addSnapshotListener { [self] (snapShot, error) in
            countArray = []
            dateFormatter.dateFormat = "yyyy年MM月dd日"
            dateFormatter.locale = Locale(identifier: "ja_JP")
            dateFormatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
            let january = dateFormatter.date(from: "\(year)年1月\(settlementDay)日")
            let february = dateFormatter.date(from: "\(year)年2月\(settlementDay)日")
            let march = dateFormatter.date(from: "\(year)年3月\(settlementDay)日")
            let april = dateFormatter.date(from: "\(year)年4月\(settlementDay)日")
            let may = dateFormatter.date(from: "\(year)年5月\(settlementDay)日")
            let june = dateFormatter.date(from: "\(year)年6月\(settlementDay)日")
            let july = dateFormatter.date(from: "\(year)年7月\(settlementDay)日")
            let august = dateFormatter.date(from: "\(year)年8月\(settlementDay)日")
            let september = dateFormatter.date(from: "\(year)年9月\(settlementDay)日")
            let october = dateFormatter.date(from: "\(year)年10月\(settlementDay)日")
            let november = dateFormatter.date(from: "\(year)年11月\(settlementDay)日")
            let december = dateFormatter.date(from: "\(year)年12月\(settlementDay)日")
            
            var januaryCount = 0
            var februaryCount = 0
            var marchCount = 0
            var aprilCount = 0
            var mayCount = 0
            var juneCount = 0
            var julyCount = 0
            var augustCount = 0
            var septemberCount = 0
            var octoberCount = 0
            var novemberCount = 0
            var decemberCount = 0
            
            if error != nil{
                activityIndicatorView.stopAnimating()
                return
            }
            if let snapShotDoc = snapShot?.documents{
                for doc in snapShotDoc{
                    let data = doc.data()
                    let paymentAmount = data["paymentAmount"] as! Int
                    let timestamp = data["paymentDay"] as! Timestamp
                    let paymentDay = timestamp.dateValue()
                    if startDate < paymentDay && paymentDay <= january!{
                        januaryCount = januaryCount + paymentAmount
                    }else if january! < paymentDay && paymentDay <= february!{
                        februaryCount = februaryCount + paymentAmount
                    }else if february! < paymentDay && paymentDay <= march!{
                        marchCount = marchCount + paymentAmount
                    }else if march! < paymentDay && paymentDay <= april!{
                        aprilCount = aprilCount + paymentAmount
                    }else if april! < paymentDay && paymentDay <= may!{
                        mayCount = mayCount + paymentAmount
                    }else if may! < paymentDay && paymentDay <= june!{
                        juneCount = juneCount + paymentAmount
                    }else if june! < paymentDay && paymentDay <= july!{
                        julyCount = julyCount + paymentAmount
                    }else if july! < paymentDay && paymentDay <= august!{
                        augustCount = augustCount + paymentAmount
                    }else if august! < paymentDay && paymentDay <= september!{
                        septemberCount = septemberCount + paymentAmount
                    }else if september! < paymentDay && paymentDay <= october!{
                        octoberCount = octoberCount + paymentAmount
                    }else if october! < paymentDay && paymentDay <= november!{
                        novemberCount = novemberCount + paymentAmount
                    }else if november! < paymentDay && paymentDay <= december!{
                        decemberCount = decemberCount + paymentAmount
                    }
                }
            }
            countArray = [januaryCount,februaryCount,marchCount,aprilCount,mayCount,juneCount,julyCount,augustCount,septemberCount,octoberCount,novemberCount,decemberCount]
            loadOKDelegate?.loadMonthlyTransition_OK?(countArray: countArray)
        }
    }
    
    //1〜12月の項目ごとの光熱費と家賃と通信費の推移
    func loadMonthlyUtilityTransition(groupID:String,year:String,settlementDay:String,startDate:Date,endDate:Date,activityIndicatorView:UIActivityIndicatorView){
        
        db.collection("paymentData").whereField("groupID", isEqualTo: groupID).whereField("paymentDay", isGreaterThanOrEqualTo: startDate).whereField("paymentDay", isLessThan: endDate).whereField("category", in: ["水道代","電気代","ガス代","家賃","通信費"]).addSnapshotListener { [self] (snapShot, error) in
            countArray = []
            dateFormatter.dateFormat = "yyyy年MM月dd日"
            dateFormatter.locale = Locale(identifier: "ja_JP")
            dateFormatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
            let january = dateFormatter.date(from: "\(year)年1月\(settlementDay)日")
            let february = dateFormatter.date(from: "\(year)年2月\(settlementDay)日")
            let march = dateFormatter.date(from: "\(year)年3月\(settlementDay)日")
            let april = dateFormatter.date(from: "\(year)年4月\(settlementDay)日")
            let may = dateFormatter.date(from: "\(year)年5月\(settlementDay)日")
            let june = dateFormatter.date(from: "\(year)年6月\(settlementDay)日")
            let july = dateFormatter.date(from: "\(year)年7月\(settlementDay)日")
            let august = dateFormatter.date(from: "\(year)年8月\(settlementDay)日")
            let september = dateFormatter.date(from: "\(year)年9月\(settlementDay)日")
            let october = dateFormatter.date(from: "\(year)年10月\(settlementDay)日")
            let november = dateFormatter.date(from: "\(year)年11月\(settlementDay)日")
            let december = dateFormatter.date(from: "\(year)年12月\(settlementDay)日")
            
            var januaryCount = 0
            var februaryCount = 0
            var marchCount = 0
            var aprilCount = 0
            var mayCount = 0
            var juneCount = 0
            var julyCount = 0
            var augustCount = 0
            var septemberCount = 0
            var octoberCount = 0
            var novemberCount = 0
            var decemberCount = 0
            
            if error != nil{
                activityIndicatorView.stopAnimating()
                return
            }
            if let snapShotDoc = snapShot?.documents{
                for doc in snapShotDoc{
                    let data = doc.data()
                    let paymentAmount = data["paymentAmount"] as! Int
                    let timestamp = data["paymentDay"] as! Timestamp
                    let paymentDay = timestamp.dateValue()
                    if startDate < paymentDay && paymentDay <= january!{
                        januaryCount = januaryCount + paymentAmount
                    }else if january! < paymentDay && paymentDay <= february!{
                        februaryCount = februaryCount + paymentAmount
                    }else if february! < paymentDay && paymentDay <= march!{
                        marchCount = marchCount + paymentAmount
                    }else if march! < paymentDay && paymentDay <= april!{
                        aprilCount = aprilCount + paymentAmount
                    }else if april! < paymentDay && paymentDay <= may!{
                        mayCount = mayCount + paymentAmount
                    }else if may! < paymentDay && paymentDay <= june!{
                        juneCount = juneCount + paymentAmount
                    }else if june! < paymentDay && paymentDay <= july!{
                        julyCount = julyCount + paymentAmount
                    }else if july! < paymentDay && paymentDay <= august!{
                        augustCount = augustCount + paymentAmount
                    }else if august! < paymentDay && paymentDay <= september!{
                        septemberCount = septemberCount + paymentAmount
                    }else if september! < paymentDay && paymentDay <= october!{
                        octoberCount = octoberCount + paymentAmount
                    }else if october! < paymentDay && paymentDay <= november!{
                        novemberCount = novemberCount + paymentAmount
                    }else if november! < paymentDay && paymentDay <= december!{
                        decemberCount = decemberCount + paymentAmount
                    }
                }
            }
            countArray = [januaryCount,februaryCount,marchCount,aprilCount,mayCount,juneCount,julyCount,augustCount,septemberCount,octoberCount,novemberCount,decemberCount]
            loadOKDelegate?.loadMonthlyTransition_OK?(countArray: countArray)
        }
    }
    
    //1〜12月の項目ごとの食費の推移
    func loadMonthlyFoodTransition(groupID:String,year:String,settlementDay:String,startDate:Date,endDate:Date,activityIndicatorView:UIActivityIndicatorView){
        
        db.collection("paymentData").whereField("groupID", isEqualTo: groupID).whereField("paymentDay", isGreaterThanOrEqualTo: startDate).whereField("paymentDay", isLessThan: endDate).whereField("category", isEqualTo: "食費").addSnapshotListener { [self] (snapShot, error) in
            
            countArray = []
            dateFormatter.dateFormat = "yyyy年MM月dd日"
            dateFormatter.locale = Locale(identifier: "ja_JP")
            dateFormatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
            let january = dateFormatter.date(from: "\(year)年1月\(settlementDay)日")
            let february = dateFormatter.date(from: "\(year)年2月\(settlementDay)日")
            let march = dateFormatter.date(from: "\(year)年3月\(settlementDay)日")
            let april = dateFormatter.date(from: "\(year)年4月\(settlementDay)日")
            let may = dateFormatter.date(from: "\(year)年5月\(settlementDay)日")
            let june = dateFormatter.date(from: "\(year)年6月\(settlementDay)日")
            let july = dateFormatter.date(from: "\(year)年7月\(settlementDay)日")
            let august = dateFormatter.date(from: "\(year)年8月\(settlementDay)日")
            let september = dateFormatter.date(from: "\(year)年9月\(settlementDay)日")
            let october = dateFormatter.date(from: "\(year)年10月\(settlementDay)日")
            let november = dateFormatter.date(from: "\(year)年11月\(settlementDay)日")
            let december = dateFormatter.date(from: "\(year)年12月\(settlementDay)日")
            
            var januaryCount = 0
            var februaryCount = 0
            var marchCount = 0
            var aprilCount = 0
            var mayCount = 0
            var juneCount = 0
            var julyCount = 0
            var augustCount = 0
            var septemberCount = 0
            var octoberCount = 0
            var novemberCount = 0
            var decemberCount = 0
            
            if error != nil{
                activityIndicatorView.stopAnimating()
                return
            }
            if let snapShotDoc = snapShot?.documents{
                for doc in snapShotDoc{
                    let data = doc.data()
                    let paymentAmount = data["paymentAmount"] as! Int
                    let timestamp = data["paymentDay"] as! Timestamp
                    let paymentDay = timestamp.dateValue()
                    if startDate < paymentDay && paymentDay <= january!{
                        januaryCount = januaryCount + paymentAmount
                    }else if january! < paymentDay && paymentDay <= february!{
                        februaryCount = februaryCount + paymentAmount
                    }else if february! < paymentDay && paymentDay <= march!{
                        marchCount = marchCount + paymentAmount
                    }else if march! < paymentDay && paymentDay <= april!{
                        aprilCount = aprilCount + paymentAmount
                    }else if april! < paymentDay && paymentDay <= may!{
                        mayCount = mayCount + paymentAmount
                    }else if may! < paymentDay && paymentDay <= june!{
                        juneCount = juneCount + paymentAmount
                    }else if june! < paymentDay && paymentDay <= july!{
                        julyCount = julyCount + paymentAmount
                    }else if july! < paymentDay && paymentDay <= august!{
                        augustCount = augustCount + paymentAmount
                    }else if august! < paymentDay && paymentDay <= september!{
                        septemberCount = septemberCount + paymentAmount
                    }else if september! < paymentDay && paymentDay <= october!{
                        octoberCount = octoberCount + paymentAmount
                    }else if october! < paymentDay && paymentDay <= november!{
                        novemberCount = novemberCount + paymentAmount
                    }else if november! < paymentDay && paymentDay <= december!{
                        decemberCount = decemberCount + paymentAmount
                    }
                }
            }
            countArray = [januaryCount,februaryCount,marchCount,aprilCount,mayCount,juneCount,julyCount,augustCount,septemberCount,octoberCount,novemberCount,decemberCount]
            loadOKDelegate?.loadMonthlyTransition_OK?(countArray: countArray)
        }
    }
    
    //1〜12月の項目ごとのその他の推移
    func loadMonthlyOthersTransition(groupID:String,year:String,settlementDay:String,startDate:Date,endDate:Date,activityIndicatorView:UIActivityIndicatorView){
        
        db.collection("paymentData").whereField("groupID", isEqualTo: groupID).whereField("paymentDay", isGreaterThanOrEqualTo: startDate).whereField("paymentDay", isLessThan: endDate).whereField("category", isEqualTo: "その他").addSnapshotListener { [self] (snapShot, error) in
            
            countArray = []
            dateFormatter.dateFormat = "yyyy年MM月dd日"
            dateFormatter.locale = Locale(identifier: "ja_JP")
            dateFormatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
            let january = dateFormatter.date(from: "\(year)年1月\(settlementDay)日")
            let february = dateFormatter.date(from: "\(year)年2月\(settlementDay)日")
            let march = dateFormatter.date(from: "\(year)年3月\(settlementDay)日")
            let april = dateFormatter.date(from: "\(year)年4月\(settlementDay)日")
            let may = dateFormatter.date(from: "\(year)年5月\(settlementDay)日")
            let june = dateFormatter.date(from: "\(year)年6月\(settlementDay)日")
            let july = dateFormatter.date(from: "\(year)年7月\(settlementDay)日")
            let august = dateFormatter.date(from: "\(year)年8月\(settlementDay)日")
            let september = dateFormatter.date(from: "\(year)年9月\(settlementDay)日")
            let october = dateFormatter.date(from: "\(year)年10月\(settlementDay)日")
            let november = dateFormatter.date(from: "\(year)年11月\(settlementDay)日")
            let december = dateFormatter.date(from: "\(year)年12月\(settlementDay)日")
            
            var januaryCount = 0
            var februaryCount = 0
            var marchCount = 0
            var aprilCount = 0
            var mayCount = 0
            var juneCount = 0
            var julyCount = 0
            var augustCount = 0
            var septemberCount = 0
            var octoberCount = 0
            var novemberCount = 0
            var decemberCount = 0
            
            if error != nil{
                activityIndicatorView.stopAnimating()
                return
            }
            if let snapShotDoc = snapShot?.documents{
                for doc in snapShotDoc{
                    let data = doc.data()
                    let paymentAmount = data["paymentAmount"] as! Int
                    let timestamp = data["paymentDay"] as! Timestamp
                    let paymentDay = timestamp.dateValue()
                    if startDate < paymentDay && paymentDay <= january!{
                        januaryCount = januaryCount + paymentAmount
                    }else if january! < paymentDay && paymentDay <= february!{
                        februaryCount = februaryCount + paymentAmount
                    }else if february! < paymentDay && paymentDay <= march!{
                        marchCount = marchCount + paymentAmount
                    }else if march! < paymentDay && paymentDay <= april!{
                        aprilCount = aprilCount + paymentAmount
                    }else if april! < paymentDay && paymentDay <= may!{
                        mayCount = mayCount + paymentAmount
                    }else if may! < paymentDay && paymentDay <= june!{
                        juneCount = juneCount + paymentAmount
                    }else if june! < paymentDay && paymentDay <= july!{
                        julyCount = julyCount + paymentAmount
                    }else if july! < paymentDay && paymentDay <= august!{
                        augustCount = augustCount + paymentAmount
                    }else if august! < paymentDay && paymentDay <= september!{
                        septemberCount = septemberCount + paymentAmount
                    }else if september! < paymentDay && paymentDay <= october!{
                        octoberCount = octoberCount + paymentAmount
                    }else if october! < paymentDay && paymentDay <= november!{
                        novemberCount = novemberCount + paymentAmount
                    }else if november! < paymentDay && paymentDay <= december!{
                        decemberCount = decemberCount + paymentAmount
                    }
                }
            }
            countArray = [januaryCount,februaryCount,marchCount,aprilCount,mayCount,juneCount,julyCount,augustCount,septemberCount,octoberCount,novemberCount,decemberCount]
            loadOKDelegate?.loadMonthlyTransition_OK?(countArray: countArray)
        }
    }
    
    //(グループの合計金額)と(1人当たりの金額)と(支払いに参加したユーザー)をロード
    func loadMonthPayment(groupID:String,userIDArray:[String],startDate:Date,endDate:Date){
        db.collection("paymentData").whereField("groupID", isEqualTo: groupID).whereField("paymentDay", isGreaterThanOrEqualTo: startDate).whereField("paymentDay", isLessThan: endDate).addSnapshotListener { (snapShot, error) in
            
            var groupPaymentOfMonth = 0
            var paymentAverageOfMonth = 0
            if error != nil{
                return
            }
            if let snapShotDoc = snapShot?.documents{
                for doc in snapShotDoc{
                    let data = doc.data()
                    let paymentAmount = data["paymentAmount"] as! Int
                    groupPaymentOfMonth = groupPaymentOfMonth + paymentAmount
                }
                if userIDArray.count == 0{
                    self.loadOKDelegate?.loadMonthPayment_OK?(groupPaymentOfMonth: groupPaymentOfMonth, paymentAverageOfMonth: paymentAverageOfMonth, userIDArray: userIDArray)
                }else{
                    let numberOfPeople = userIDArray.count
                    paymentAverageOfMonth = groupPaymentOfMonth / numberOfPeople
                    self.loadOKDelegate?.loadMonthPayment_OK?(groupPaymentOfMonth: groupPaymentOfMonth, paymentAverageOfMonth: paymentAverageOfMonth, userIDArray: userIDArray)
                }
                
            }
        }
    }
    
    //グループの支払状況のロード
    //各メンバーの支払い金額を取得するロード
    func loadMonthSettlement(groupID:String,userID:String?,startDate:Date,endDate:Date){
        if userID == nil{
            db.collection("paymentData").whereField("groupID", isEqualTo: groupID).whereField("paymentDay", isGreaterThanOrEqualTo: startDate).whereField("paymentDay", isLessThan: endDate).addSnapshotListener { (snapShot, error) in
                
                self.settlementSets = []
                if error != nil{
                    return
                }
                if let snapShotDoc = snapShot?.documents{
                    for doc in snapShotDoc{
                        let data = doc.data()
                        let paymentAmount = data["paymentAmount"] as! Int
                        let userID = data["userID"] as! String
                        let newData = SettlementSets(paymentAmount: paymentAmount, userID: userID)
                        self.settlementSets.append(newData)
                    }
                    self.loadOKDelegate?.loadMonthSettlement_OK?()
                }
            }
        }else{
            db.collection("paymentData").whereField("groupID", isEqualTo: groupID).whereField("userID", isEqualTo: userID!).whereField("paymentDay", isGreaterThanOrEqualTo: startDate).whereField("paymentDay", isLessThan: endDate).addSnapshotListener { (snapShot, error) in
                
                self.settlementSets = []
                var myTotalPay = 0
                if error != nil{
                    print(error.debugDescription)
                    return
                }
                if let snapShotDoc = snapShot?.documents{
                    for doc in snapShotDoc{
                        let data = doc.data()
                        let paymentAmount = data["paymentAmount"] as! Int
                        //自分の支払い合計金額
                        myTotalPay = myTotalPay + paymentAmount
                    }
                    let newData = SettlementSets(paymentAmount: myTotalPay, userID: nil)
                    self.settlementSets.append(newData)
                    self.loadOKDelegate?.loadMonthSettlement_OK?()
                }
                
            }
        }
    }
    
}

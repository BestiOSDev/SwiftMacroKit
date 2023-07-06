import SwiftUI
import Foundation
import SwiftMacroKit
import SwiftMacroKitMacros


/*
 regular font-weight: 400
 medium font-weight: 500
 bold font-weight: 600
 thin font-weight: 300
 */
public enum PingFangSC: String {
    case light = "PingFangSC-Light",
         bold = "PingFangSC-Semibold",
         regular = "PingFangSC-Regular",
         medium = "PingFangSC-Medium"
}

//let a = 17
//let b = 25
//let c = a + b
//let (result, code) = #stringify(a + b)
//
//let (result2, code2) = #stringify(<#T##value: T##T#>)
//
//print("The value \(result) was produced by the code \"\(code)\"")

let url: URL = #URL("https://www.baidu.com")
debugPrint(url)

//let font: Font = #PingFangSC(.regular, fontSize: 15.0)
//debugPrint(font)
if #available(macOS 11.0, *) {
    let font1 = #PingFangFont(.light, fontSize: 15.0)
    debugPrint(font1)
    let font2 = #PingFangFont(.medium, fontSize: 15.0)
    debugPrint(font2)
} else {
    // Fallback on earlier versions
}


public struct MyConstaints {
    #Constant("app_id")
    #Constant("empty_image")
    #Constant("error_tip")
    @AddCompletionHandler()
    func fetchDetail(_ id: Int) async -> String? {
        return "hello world"
    }
}

public struct UserModel {
    @UserDefault(key: "nickNameKey")
    var nickName: String?
    @UserDefault(key: "accountIdKey")
    var accountId: String?
    @UserDefault(key: "isVipKey")
    var isVip: Bool?
    @UserDefault(key: "ageKey")
    var age: Int?
    @UserDefault(key: "heightKey")
    var height: Float?
}

@StateProperties
struct OldStorage {    
    var x: Int
    var y: Int
}

protocol MyCustomProtocol {
    func foo()
}

@Description
class BusinessModel {
    var count: Int = 0
    var tag: String?
    init(count: Int, tag: String? = nil) {
        self.count = count
        self.tag = tag
    }
}


MyConstaints.appId = "123"
debugPrint(MyConstaints.appId)

let const = MyConstaints()
//Task {
//    let result = await const.fetchDetail(100)
//    debugPrint(result)
//}
const.fetchDetail(100) { element in
    debugPrint(element ?? "")
}

var userModel = UserModel()
userModel.nickName = "230"
userModel.accountId = "12"
//userModel.isVip = true

let business = BusinessModel(count: 0)
business.count = 10
business.tag = "商场"


debugPrint(business)


while true {
    
}

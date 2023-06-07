//
//  MKDetailsController.swift
//  AgentBackends
//
//  Created by 邓磊 on 2022/12/16.
//  Copyright © 2022 soudian. All rights reserved.
//


import Foundation
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class MKDetailsController: MKGenericController {
    public static let encryptURL = "https://biz-app.sd.zhumanggroup.com/api/"
    public static let encryptJavaURL = "https://apigateway.sd.zhumanggroup.com"
    
    enum EDetailsView {
        case info
        case request
        case response
    }
    
    private enum Constants: String {
        case headersTitle = "-- Headers --\n\n"
        case bodyTitle = "\n-- Body --\n\n"
        case tooLongToShowTitle = "内容太长，请点击下面的按钮查看详情\n"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    func getInfoStringFromObject(_ object: MKHTTPModel) -> NSAttributedString {
        var tempString: String
        tempString = String()
        
        tempString += "[URL] \n\(object.requestURL ?? "")\n\n"
        tempString += "[Method] \n\(object.requestMethod ?? "")\n\n"
        if !(object.noResponse) {
            tempString += "[Status] \n\(object.responseStatus ?? 0)\n\n"
        }
        tempString += "[Request date] \n\(object.requestDate ?? Date())\n\n"
        if !(object.noResponse) {
            tempString += "[Response date] \n\(object.responseDate  ?? Date())\n\n"
            tempString += "[Time interval] \n\(object.timeInterval ?? 0)\n\n"
        }
        tempString += "[Timeout] \n\(object.requestTimeout ?? "")\n\n"
        tempString += "[Cache policy] \n\(object.requestCachePolicy ?? "")\n\n"
        
        return formatMKString(tempString)
    }

    func getRequestStringFromObject(_ object: MKHTTPModel) -> NSAttributedString {
        var tempString: String
        tempString = String()
        
        tempString += Constants.headersTitle.rawValue
        
        if object.requestHeaders?.count > 0 {
            for (key, val) in (object.requestHeaders)! {
                tempString += "[\(key)] \n\(val)\n\n"
            }
        } else {
            tempString += "Request headers are empty\n\n"
        }
        
        tempString += getRequestBodyStringFooter(object)
        return formatMKString(tempString)
    }

    func getRequestBodyStringFooter(_ object: MKHTTPModel) -> String {
        var tempString = Constants.bodyTitle.rawValue
        if (object.requestBodyLength == 0) {
            tempString += "Request body is empty\n"
        } else if (object.requestBodyLength > 1024) {
            tempString += Constants.tooLongToShowTitle.rawValue
        } else {
            if object.requestURL?.hasPrefix(MKDetailsController.encryptURL) == true || object.requestURL?.hasPrefix(MKDetailsController.encryptJavaURL) == true{
                tempString += "\(SDISApiTool().Decrypt(result: object.getRequestBody()).jsonString(prettify: true) ?? "")\n"
            }else{
                tempString += "\(object.getRequestBody())\n"
            }
        }
        return tempString
    }
    
    func getResponseStringFromObject(_ object: MKHTTPModel) -> NSAttributedString {
        if (object.noResponse) {
            return NSMutableAttributedString(string: "No response")
        }
        
        var tempString: String
        tempString = String()
        
        tempString += Constants.headersTitle.rawValue
        
        if object.responseHeaders?.count > 0 {
            for (key, val) in object.responseHeaders! {
                tempString += "[\(key)] \n\(val)\n\n"
            }
        } else {
            tempString += "Response headers are empty\n\n"
        }
        
        tempString += getResponseBodyStringFooter(object)
        return formatMKString(tempString)
    }
    
    func getResponseBodyStringFooter(_ object: MKHTTPModel) -> String {
        var tempString = Constants.bodyTitle.rawValue
        if (object.responseBodyLength == 0) {
            tempString += "Response body is empty\n"
        } else if (object.responseBodyLength > 1024) {
            tempString += Constants.tooLongToShowTitle.rawValue
        } else {
            if object.requestURL?.hasPrefix(MKDetailsController.encryptURL) == true || object.requestURL?.hasPrefix(MKDetailsController.encryptJavaURL) == true{
                tempString += "\(SDISApiTool().Decrypt(result: object.getResponseBody()).jsonString(prettify: true) ?? "")\n"
            }else{
                tempString += "\(object.getResponseBody())\n"
            }
        }
        return tempString
    }

}

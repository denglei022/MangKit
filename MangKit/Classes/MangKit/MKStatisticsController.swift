//
//  MKStatisticsController.swift
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


class MKStatisticsController: MKGenericController {
    var totalModels: Int = 0

    var successfulRequests: Int = 0
    var failedRequests: Int = 0
    
    var totalRequestSize: Int = 0
    var totalResponseSize: Int = 0
    
    var totalResponseTime: Float = 0
    
    var fastestResponseTime: Float = 999
    var slowestResponseTime: Float = 0
    
    private lazy var dataSubscription = Subscription<[MKHTTPModel]> { [weak self] in self?.reloadData(with: $0) }
    
    deinit {
        dataSubscription.cancel()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        MKHTTPModelManager.shared.publisher.subscribe(dataSubscription)
        reloadData(with: MKHTTPModelManager.shared.filteredModels)
    }
    
    
    func getReportString() -> NSAttributedString {
        var tempString: String
        tempString = String()
        
        tempString += "[总请求次数] \n\(totalModels)\n\n"
        
        tempString += "[请求成功次数] \n\(successfulRequests)\n\n"
        tempString += "[请求失败次数] \n\(failedRequests)\n\n"
        
        tempString += "[总请求大小] \n\(Float(totalRequestSize/1024)) KB\n\n"
        if totalModels == 0 {
            tempString += "[平均请求大小] \n0.0 KB\n\n"
        } else {
            tempString += "[平均请求大小] \n\(Float((totalRequestSize/totalModels)/1024)) KB\n\n"
        }
        
        tempString += "[总响应大小] \n\(Float(totalResponseSize/1024)) KB\n\n"
        if totalModels == 0 {
            tempString += "[平均响应大小] \n0.0 KB\n\n"
        } else {
            tempString += "[平均响应大小] \n\(Float((totalResponseSize/totalModels)/1024)) KB\n\n"
        }

        if self.totalModels == 0 {
            tempString += "[平均响应时长] \n0.0s\n\n"
            tempString += "[最快响应时长] \n0.0s\n\n"
        } else {
            tempString += "[平均响应时长] \n\(Float(totalResponseTime/Float(totalModels)))s\n\n"
            if fastestResponseTime == 999 {
                tempString += "[最快响应时长] \n0.0s\n\n"
            } else {
                tempString += "[最快响应时长] \n\(fastestResponseTime)s\n\n"
            }
        }
        tempString += "[最慢响应时长] \n\(slowestResponseTime)s\n\n"

        return formatMKString(tempString)
    }
    
    private func reloadData(with models: [MKHTTPModel]) {
        clearStatistics()
        generateStatistics(models)
        reloadData()
    }
    
    private func generateStatistics(_ models: [MKHTTPModel]) {
        totalModels = models.count
        
        for model in models {
            
            if model.isSuccessful() {
                successfulRequests += 1
            } else  {
                failedRequests += 1
            }
            
            if (model.requestBodyLength != nil) {
                totalRequestSize += model.requestBodyLength!
            }
            
            if (model.responseBodyLength != nil) {
                totalResponseSize += model.responseBodyLength!
            }
            
            if (model.timeInterval != nil) {
                totalResponseTime += model.timeInterval!
                
                if model.timeInterval < fastestResponseTime {
                    fastestResponseTime = model.timeInterval!
                }
                
                if model.timeInterval > slowestResponseTime {
                    slowestResponseTime = model.timeInterval!
                }
            }
        }
    }
    
    private func clearStatistics() {
        totalModels = 0
        successfulRequests = 0
        failedRequests = 0
        totalRequestSize = 0
        totalResponseSize = 0
        totalResponseTime = 0
        fastestResponseTime = 999
        slowestResponseTime = 0
    }
    
}

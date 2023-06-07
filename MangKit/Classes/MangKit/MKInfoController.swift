//
//  MKInfoController.swift
//  AgentBackends
//
//  Created by 邓磊 on 2022/12/16.
//  Copyright © 2022 soudian. All rights reserved.
//
    
import Foundation

class MKInfoController: MKGenericController {
    
    func generateInfoString(_ ipAddress: String) -> NSAttributedString {
        var tempString: String
        tempString = String()
        
        tempString += "[App 名称] \n\(MKDebugInfo.getMKAppName())\n\n"
        
        tempString += "[APP 版本] \n\(MKDebugInfo.getMKAppVersionNumber()) (build \(MKDebugInfo.getMKAppBuildNumber()))\n\n"
        
        tempString += "[APP 包名] \n\(MKDebugInfo.getMKBundleIdentifier())\n\n"

        tempString += "[设备系统] \niOS \(MKDebugInfo.getMKOSVersion())\n\n"

        tempString += "[设备类型] \n\(MKDebugInfo.getMKDeviceType())\n\n"

        tempString += "[屏幕尺寸] \n\(MKDebugInfo.getMKDeviceScreenResolution())\n\n"
        
        tempString += "[IP地址] \n\(ipAddress)\n\n"

        return formatMKString(tempString)
    }
}

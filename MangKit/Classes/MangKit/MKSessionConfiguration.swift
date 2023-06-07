//
//  MKSessionConfiguration.swift
//  AgentBackends
//
//  Created by 邓磊 on 2022/12/16.
//  Copyright © 2022 soudian. All rights reserved.
//

import UIKit

class MKSessionConfiguration: NSObject {

    static var `default` = MKSessionConfiguration()
    
    var isSwizzle = false
    
    func load(){
        self.isSwizzle = true
        let cls: AnyClass? = NSClassFromString("__NSCFURLSessionConfiguration") ?? NSClassFromString("NSURLSessionConfiguration")
        
        let originalSelector = #selector(self.protocolClasses)
        let swizzledSelector = #selector(MKSessionConfiguration.protocolClasses)
        
        swizzleSelector(orginal_selector: originalSelector, to_selector: swizzledSelector, from: cls, to: type(of: self))
    }
    
    func unload(){
        self.isSwizzle = false
        let cls: AnyClass? = NSClassFromString("__NSCFURLSessionConfiguration") ?? NSClassFromString("NSURLSessionConfiguration")
        
        let originalSelector = #selector(self.protocolClasses)
        let swizzledSelector = #selector(MKSessionConfiguration.protocolClasses)
        
        swizzleSelector(orginal_selector: swizzledSelector, to_selector: originalSelector, from: type(of: self), to: cls)
    }
    
    
    func swizzleSelector(orginal_selector: Selector, to_selector: Selector, from original: AnyClass?, to stub: AnyClass?) {
        let originalMethod = class_getInstanceMethod(original, orginal_selector)
        let stubMethod = class_getInstanceMethod(stub, to_selector)
        if originalMethod == nil || stubMethod == nil {
//            NSException.raise(NSExceptionName.internalInconsistencyException, format: "Couldn't load NEURLSessionConfiguration.", arguments: CVaListPointer())
        }
        if let originalMethod, let stubMethod {
            method_exchangeImplementations(originalMethod, stubMethod)
        }
    }
    
    /// 开始监听
    func startMonitor() {
        let sessionConfiguration = MKSessionConfiguration.default
        MK.sharedInstance().start()
        URLProtocol.registerClass(MKProtocol.self)
        if !sessionConfiguration.isSwizzle{
            sessionConfiguration.load()
        }
    }
    
    /// 停止监听
    func stopMonitor() {
        let sessionConfiguration = MKSessionConfiguration.default
        MK.sharedInstance().stop()
        URLProtocol.unregisterClass(MKProtocol.self)
        if sessionConfiguration.isSwizzle{
            sessionConfiguration.unload()
        }
        
    }
    
    @objc func protocolClasses() -> [ AnyObject ]{
        // 如果还有其他的监控protocol，也可以在这里加进去
        return [MKProtocol.self]
    }
    
}

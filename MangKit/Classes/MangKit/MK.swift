//
//  MK.swift
//  AgentBackends
//
//  Created by 邓磊 on 2022/12/16.
//  Copyright © 2022 soudian. All rights reserved.
//

import Foundation
import UIKit

private func podPlistVersion() -> String? {
    guard let path = Bundle(identifier: "com.zhumang.mk")?.infoDictionary?["CFBundleShortVersionString"] as? String else { return nil }
    return path
}

// TODO: Carthage support
let mkVersion = podPlistVersion() ?? "1.0.0"
let btnWidth = 60.0

@objc
open class MK: NSObject {

    public var mkMenuDelegate: MKMenuFuncDelegate?
    
    fileprivate var navigationViewController: UINavigationController?
    
    fileprivate enum Constants: String {
        case alreadyStartedMessage = "Already started!"
        case alreadyStoppedMessage = "Already stopped!"
        case startedMessage = "Started!"
        case stoppedMessage = "Stopped!"
    }
    
    fileprivate var started: Bool = false
    fileprivate var presented: Bool = false
    fileprivate var enabled: Bool = false
    fileprivate var filterd: Bool = false
    fileprivate var selectedGesture: MKGesture = .shake
    fileprivate var ignoredURLs = [String]()
    fileprivate var ignoredURLsRegex = [NSRegularExpression]()
    fileprivate var lastVisitDate: Date = Date()
    
    internal var cacheStoragePolicy = URLCache.StoragePolicy.notAllowed
    
    // swiftSharedInstance is not accessible from ObjC
    class var swiftSharedInstance: MK {
        struct Singleton {
            static let instance = MK()
        }
        return Singleton.instance
    }
    
    // the sharedInstance class method can be reached from ObjC
    @objc open class func sharedInstance() -> MK {
        return MK.swiftSharedInstance
    }
    
    @objc public enum MKGesture: Int {
        case shake
        case custom
    }

    @objc open func start() {
        guard !started else {
            showMessage(Constants.alreadyStartedMessage.rawValue)
            return
        }

        started = true
        URLSessionConfiguration.implementMK()
        register()
        enable()
        fileStorageInit()
        showMessage(Constants.startedMessage.rawValue)
        
        if UserDefaults.standard.bool(forKey: "isShowLogo"){
            showLogo()
        }
    }
    
    @objc open func stop() {
        guard started else {
            showMessage(Constants.alreadyStoppedMessage.rawValue)
            return
        }
        
        unregister()
        disable()
        clearOldData()
        started = false
        showMessage(Constants.stoppedMessage.rawValue)
    }
    
    fileprivate func showMessage(_ msg: String) {
        print("mkVersion \(mkVersion) : \(msg)")
    }
    
    internal func isEnabled() -> Bool {
        return enabled
    }
    
    internal func enable() {
        enabled = true
    }
    
    internal func disable() {
        enabled = false
    }
    
    internal func isFilterd() -> Bool {
        return filterd
    }
    
    internal func filter() {
        filterd = true
    }
    
    internal func disableFilter() {
        filterd = false
    }
    

    
    fileprivate func register() {
        URLProtocol.registerClass(MKProtocol.self)
    }
    
    fileprivate func unregister() {
        URLProtocol.unregisterClass(MKProtocol.self)
    }
    
    @objc func motionDetected() {
        guard started else { return }
        toggleMK()
    }
    
    @objc open func isStarted() -> Bool {
        return started
    }
    
    @objc open func setCachePolicy(_ policy: URLCache.StoragePolicy) {
        cacheStoragePolicy = policy
    }
    
    @objc open func setGesture(_ gesture: MKGesture) {
        selectedGesture = gesture
    }
    
    @objc open func show() {
//        guard started else { return }
        showMK()
    }
    
    @objc open func showLogo() {
        guard started else { return }
        UserDefaults.standard.set(true, forKey: "isShowLogo")
        UserDefaults.standard.synchronize()
        self.logoBtn.isHidden = false
        currentWindow()?.addSubview(self.logoBtn)
        currentWindow()?.bringSubview(toFront: self.logoBtn)
    }
    
    @objc open func hideLogo() {
        guard started else { return }
        UserDefaults.standard.set(false, forKey: "isShowLogo")
        UserDefaults.standard.synchronize()
        self.logoBtn.isHidden = true
    }
    
    #if os(iOS)
    @objc open func show(on rootViewController: UIViewController) {
        guard started, presented == false else { return }

        showMK(on: rootViewController)
        presented = true
    }
    #endif
    
    @objc open func hide() {
        guard started else { return }
        hideMK()
    }

    @objc open func toggle()
    {
        guard self.started else { return }
        toggleMK()
    }
    
    @objc open func ignoreURL(_ url: String) {
        ignoredURLs.append(url)
    }
    
    @objc open func getSessionLog() -> Data? {
        return try? Data(contentsOf: MKPath.sessionLogURL)
    }
    
    @objc open func ignoreURLs(_ urls: [String]) {
        ignoredURLs.append(contentsOf: urls)
    }
    
    @objc open func ignoreURLsWithRegex(_ regex: String) {
        ignoredURLsRegex.append(NSRegularExpression(regex))
    }
    
    @objc open func ignoreURLsWithRegexes(_ regexes: [String]) {
        ignoredURLsRegex.append(contentsOf: regexes.map { NSRegularExpression($0) })
    }
    
    @objc open func removeIgnoreURLsRegexes() {
        ignoredURLsRegex.removeAll()
    }
    
    internal func getLastVisitDate() -> Date {
        return lastVisitDate
    }
    
    fileprivate func showMK() {
//        if presented {
//            return
//        }
        
        showMKFollowingPlatform()
        presented = true
    }
    
    fileprivate func hideMK() {
        if !presented {
            return
        }
        
        hideMKFollowingPlatform { () -> Void in
            self.presented = false
            self.lastVisitDate = Date()
        }
    }

    fileprivate func toggleMK() {
//        presented ? hideMK() : showMK()
    }
    
    private func fileStorageInit() {
        clearOldData()
        MKPath.deleteOldMKLogs()
        MKPath.createMKDirIfNotExist()
    }
    
    internal func clearOldData() {
        MKHTTPModelManager.shared.clear()
        
        MKPath.deleteMKDir()
        MKPath.createMKDirIfNotExist()
    }
    
    internal func clearLogData() {
        MKJSModelManager.shared.clear()
    }
    
    func getIgnoredURLs() -> [String] {
        return ignoredURLs
    }
    
    func getIgnoredURLsRegexes() -> [NSRegularExpression] {
        return ignoredURLsRegex
    }
    
    func getSelectedGesture() -> MKGesture {
        return selectedGesture
    }
    
    /// 获取当前window
    func currentWindow() -> UIWindow? {
        if #available(iOS 14.0, *) {
            if let window = UIApplication.shared.connectedScenes.map({$0 as? UIWindowScene}).compactMap({$0}).first?.windows.first {
                return window
            }else if let window = UIApplication.shared.delegate?.window {
                return window
            }   else{
                return nil
            }
        } else if #available(iOS 13.0, *) {
            if let window = UIApplication.shared.connectedScenes.filter({$0.activationState == .foregroundActive}) .map({$0 as? UIWindowScene})
                .compactMap({$0})
                .first?.windows
                .filter({$0.isKeyWindow}).first{
                return window
            }else if let window = UIApplication.shared.delegate?.window {
                return window
            }else{
                return nil
            }
        }else{
            if let window = UIApplication.shared.delegate?.window {
                return window
            }else{
                return nil
            }
        }
    }
    
    lazy var logoBtn: MKFloatingBtn = {
        let button = MKFloatingBtn(frame: CGRect(x: (currentWindow()?.frame.width ?? 50) - 50, y: (currentWindow()?.frame.height ?? 0)/2 - 25, width: 50, height: 50))
        button.setImage(UIImage(named: "icon_mk_logo"), for: .normal)
        button.delegate = self
        button.layer.cornerRadius = 16
        button.layer.zPosition = 999
        button.layer.masksToBounds = true
        return button
    }()
}

extension MK: FloatDelegate {
    // 实现FloatDelegate代理方法
    func singleClick() {
        print("单击")
        self.show()
    }
    
    func repeatClick() {
        print("双击")
    }
}

extension MK {
    fileprivate var presentingViewController: UIViewController? {
        var rootViewController = UIWindow.keyWindow?.rootViewController
        while let controller = rootViewController?.presentedViewController {
            rootViewController = controller
        }
        return rootViewController
    }

    fileprivate func showMKFollowingPlatform() {
        showMK(on: presentingViewController)
    }
    
    fileprivate func showMK(on rootViewController: UIViewController?) {
        let navigationController = UINavigationController(rootViewController: MKMenuViewController())
        navigationController.navigationBar.isTranslucent = false
        navigationController.navigationBar.tintColor = UIColor.MKOrangeColor()
        navigationController.navigationBar.barTintColor = UIColor.MKStarkWhiteColor()
        navigationController.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.MKOrangeColor()]

        if #available(iOS 13.0, *) {
            let appearence = UINavigationBarAppearance()
            
            appearence.configureWithOpaqueBackground()
            appearence.backgroundColor = UIColor.MKStarkWhiteColor()
            appearence.titleTextAttributes = [.foregroundColor: UIColor.black]
            
            navigationController.navigationBar.standardAppearance = appearence
            navigationController.navigationBar.scrollEdgeAppearance = appearence
            
            if #available(iOS 15.0, *) {
                navigationController.navigationBar.compactScrollEdgeAppearance = appearence
            }
            
            navigationController.presentationController?.delegate = self
        }
        
        rootViewController?.present(navigationController, animated: true, completion: nil)
        navigationViewController = navigationController
    }
    
    fileprivate func hideMKFollowingPlatform(_ completion: (() -> Void)?) {
        navigationViewController?.presentingViewController?.dismiss(animated: true, completion: completion)
        navigationViewController = nil
    }
}

extension MK: UIAdaptivePresentationControllerDelegate {

    public func presentationControllerDidDismiss(_ presentationController: UIPresentationController)
    {
        guard self.started else { return }
        self.presented = false
    }
}


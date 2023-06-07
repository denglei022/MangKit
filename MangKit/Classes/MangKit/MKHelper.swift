//
//  MKHelper.swift
//  AgentBackends
//
//  Created by 邓磊 on 2022/12/16.
//  Copyright © 2022 soudian. All rights reserved.
//

import Foundation
import UIKit

public enum HTTPModelShortType: String, CaseIterable {
    case JSON = "JSON"
    case XML = "XML"
    case HTML = "HTML"
    case IMAGE = "Image"
    case OTHER = "Other"
}


public extension HTTPModelShortType {
    
    init(contentType: String) {
        if NSPredicate(format: "SELF MATCHES %@", "^application/(vnd\\.(.*)\\+)?json$").evaluate(with: contentType) {
            self = .JSON
        } else if (contentType == "application/xml") || (contentType == "text/xml")  {
            self = .XML
        } else if contentType == "text/html" {
            self = .HTML
        } else if contentType.hasPrefix("image/") {
            self = .IMAGE
        } else {
            self = .OTHER
        }
    }
}


extension MKColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(netHex: Int) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
    }
    
    class func MKOrangeColor() -> MKColor {
        return MKColor.init(netHex: 0x4583fe)
    }
    
    class func MKGreenColor() -> MKColor {
        return MKColor.init(netHex: 0x38bb93)
    }
    
    class func MKDarkGreenColor() -> MKColor {
        return MKColor.init(netHex: 0x2d7c6e)
    }
    
    class func MKRedColor() -> MKColor {
        return MKColor.init(netHex: 0xd34a33)
    }
    
    class func MKDarkRedColor() -> MKColor {
        return MKColor.init(netHex: 0x643026)
    }
    
    class func MKStarkWhiteColor() -> MKColor {
        return MKColor.init(netHex: 0xf4f5f6)
    }
    
    class func MKDarkStarkWhiteColor() -> MKColor {
        return MKColor.init(netHex: 0x9b958d)
    }
    
    class func MKLightGrayColor() -> MKColor {
        return MKColor.init(netHex: 0x9b9b9b)
    }
    
    class func MKGray44Color() -> MKColor {
        return MKColor.init(netHex: 0x707070)
    }
    
    class func MKGray95Color() -> MKColor {
        return MKColor.init(netHex: 0xf2f2f2)
    }
    
    class func MKBlackColor() -> MKColor {
        return MKColor.init(netHex: 0x231f20)
    }
    
    class func MKBlueColor() -> MKColor {
        return MKColor.init(netHex: 0x4583fe)
    }
}

extension MKFont {
    #if os(iOS)
    class func MKFont(size: CGFloat) -> UIFont {
        return UIFont(name: "HelveticaNeue", size: size)!
    }
    
    class func MKFontBold(size: CGFloat) -> UIFont {
        return UIFont(name: "HelveticaNeue-Bold", size: size)!
    }
    
    #elseif os(OSX)
    class func MKFont(size: CGFloat) -> NSFont {
        return NSFont(name: "HelveticaNeue", size: size)!
    }
    
    class func MKFontBold(size: CGFloat) -> NSFont {
        return NSFont(name: "HelveticaNeue-Bold", size: size)!
    }
    #endif
}

extension URLRequest {
    func getMKURL() -> String {
        if (url != nil) {
            return url!.absoluteString;
        } else {
            return "-"
        }
    }
    
    func getMKURLComponents() -> URLComponents? {
        guard let url = self.url else {
            return nil
        }
        return URLComponents(string: url.absoluteString)
    }
    
    func getMKMethod() -> String {
        if (httpMethod != nil) {
            return httpMethod!
        } else {
            return "-"
        }
    }
    
    func getMKCachePolicy() -> String {
        switch cachePolicy {
        case .useProtocolCachePolicy: return "UseProtocolCachePolicy"
        case .reloadIgnoringLocalCacheData: return "ReloadIgnoringLocalCacheData"
        case .reloadIgnoringLocalAndRemoteCacheData: return "ReloadIgnoringLocalAndRemoteCacheData"
        case .returnCacheDataElseLoad: return "ReturnCacheDataElseLoad"
        case .returnCacheDataDontLoad: return "ReturnCacheDataDontLoad"
        case .reloadRevalidatingCacheData: return "ReloadRevalidatingCacheData"
        @unknown default: return "Unknown \(cachePolicy)"
        }
    }
    
    func getMKTimeout() -> String {
        return String(Double(timeoutInterval))
    }
    
    func getMKHeaders() -> [AnyHashable: Any] {
        if let httpHeaders = allHTTPHeaderFields {
            return httpHeaders
        } else {
            return Dictionary()
        }
    }
    
    func getMKBody() -> Data {
        return httpBodyStream?.readfully() ?? URLProtocol.property(forKey: "MKBodyData", in: self) as? Data ?? Data()
    }
    
    func getCurl() -> String {
        guard let url = url else { return "" }
        let baseCommand = "curl \"\(url.absoluteString)\""
        
        var command = [baseCommand]
        
        if let method = httpMethod {
            command.append("-X \(method)")
        }
        
        for (key, value) in getMKHeaders() {
            command.append("-H \u{22}\(key): \(value)\u{22}")
        }
        
        if let body = String(data: getMKBody(), encoding: .utf8) {
            command.append("-d \u{22}\(body)\u{22}")
        }
        
        return command.joined(separator: " ")
    }
}

extension URLResponse {
    func getMKStatus() -> Int {
        return (self as? HTTPURLResponse)?.statusCode ?? 999
    }
    
    func getMKHeaders() -> [AnyHashable: Any] {
        return (self as? HTTPURLResponse)?.allHeaderFields ?? [:]
    }
}

extension MKImage {
    class func MKSettings() -> MKImage {
        #if os (iOS)
        return UIImage(data: MKAssets.getImage(MKAssetName.settings), scale: 1.7)!
        #elseif os(OSX)
        return NSImage(data: MKAssets.getImage(MKAssetName.settings))!
        #endif
    }

    class func MKClose() -> MKImage {
        #if os (iOS)
        return UIImage(data: MKAssets.getImage(MKAssetName.close), scale: 1.7)!
        #elseif os(OSX)
        return NSImage(data: MKAssets.getImage(MKAssetName.close))!
        #endif
    }
    
    class func MKInfo() -> MKImage {
        #if os (iOS)
        return UIImage(data: MKAssets.getImage(MKAssetName.info), scale: 1.7)!
        #elseif os(OSX)
        return NSImage(data: MKAssets.getImage(MKAssetName.info))!
        #endif
    }
    
    class func MKStatistics() -> MKImage {
        #if os (iOS)
        return UIImage(data: MKAssets.getImage(MKAssetName.statistics), scale: 1.7)!
        #elseif os(OSX)
        return NSImage(data: MKAssets.getImage(MKAssetName.statistics))!
        #endif
    }
}

extension InputStream {
  func readfully() -> Data {
    var result = Data()
    var buffer = [UInt8](repeating: 0, count: 4096)
    
    open()
    
    var amount = 0
    repeat {
      amount = read(&buffer, maxLength: buffer.count)
      if amount > 0 {
        result.append(buffer, count: amount)
      }
    } while amount > 0
    
    close()
    
    return result
  }
}

extension Date {
    func isGreaterThanDate(_ dateToCompare: Date) -> Bool {
        return compare(dateToCompare) == ComparisonResult.orderedDescending
    }
}

class MKDebugInfo {
    
    class func getMKAppName() -> String {
        return Bundle.main.infoDictionary?["CFBundleName"] as? String ?? ""
    }
    
    class func getMKAppVersionNumber() -> String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    }
    
    class func getMKAppBuildNumber() -> String {
        return Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""
    }
    
    class func getMKBundleIdentifier() -> String {
        return Bundle.main.bundleIdentifier ?? ""
    }
    
    class func getMKOSVersion() -> String {
        #if os(iOS)
        return UIDevice.current.systemVersion
        #elseif os(OSX)
        return ProcessInfo.processInfo.operatingSystemVersionString
        #endif
    }
    
    class func getMKDeviceType() -> String {
        #if os(iOS)
        return UIDevice.getMKDeviceType()
        #elseif os(OSX)
        return "Not implemented yet. PR welcomes"
        #endif
    }
    
    class func getMKDeviceScreenResolution() -> String {
        #if os(iOS)
        let scale = UIScreen.main.scale
        let bounds = UIScreen.main.bounds
        let width = bounds.size.width * scale
        let height = bounds.size.height * scale
        return "\(width) x \(height)"
        #elseif os(OSX)
        return "0"
        #endif
    }
    
    class func getMKIP(_ completion:@escaping (_ result: String) -> Void) {
        var req: NSMutableURLRequest
        req = NSMutableURLRequest(url: URL(string: "https://api.ipify.org/?format=json")!)
        URLProtocol.setProperty(true, forKey: MKProtocol.MKInternalKey, in: req)
        
        let session = URLSession.shared
        session.dataTask(with: req as URLRequest, completionHandler: { (data, response, error) in
            do {
                let rawJsonData = try JSONSerialization.jsonObject(with: data!, options: [.allowFragments])
                if let ipAddress = (rawJsonData as AnyObject).value(forKey: "ip") {
                    completion(ipAddress as! String)
                } else {
                    completion("-")
                }
            } catch {
                completion("-")
            }
            
        }) .resume()
    }
    
}


struct MKPath {
    
    static let sessionLogName = "session.log"
    static let tmpDirURL = URL(fileURLWithPath: NSTemporaryDirectory())
    static let MKDirURL = tmpDirURL.appendingPathComponent("MK", isDirectory: true)
    static let sessionLogURL = MKDirURL.appendingPathComponent(sessionLogName)
    
    static func createMKDirIfNotExist() {
        do {
            try FileManager.default.createDirectory(at: MKDirURL, withIntermediateDirectories: true, attributes: nil)
        } catch let error {
            print("[MK]: failed to create working dir - \(error.localizedDescription)")
        }
    }
    
    static func deleteMKDir() {
        guard FileManager.default.fileExists(atPath: MKDirURL.path, isDirectory: nil) else { return }
        
        do {
            try FileManager.default.removeItem(at: MKDirURL)
        } catch let error {
            print("[MK]: failed to delete working dir - \(error.localizedDescription)")
        }
    }
    
    static func deleteOldMKLogs() {
        let oldSessionLogName = "session.log"
        let oldRequestPrefixName = "MK_re"
        let fileManager = FileManager.default
        guard let documentsDir = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first,
              let fileEnumarator = fileManager.enumerator(at: documentsDir, includingPropertiesForKeys: nil, options: [.skipsSubdirectoryDescendants], errorHandler: nil) else { return }
        
        for case let fileURL as URL in fileEnumarator {
            if fileURL.lastPathComponent == oldSessionLogName || fileURL.lastPathComponent.hasPrefix(oldRequestPrefixName) {
                try? fileManager.removeItem(at: fileURL)
            }
        }
    }
    
    static func pathURLToFile(_ fileName: String) -> URL {
        return MKDirURL.appendingPathComponent(fileName)
    }
     
}


extension String {
    
    func appendToFileURL(_ fileURL: URL) {
        guard let fileHandle = try? FileHandle(forWritingTo: fileURL) else {
            write(to: fileURL)
            return
        }

        let data = data(using: .utf8)!
        
        if #available(iOS 13.4, *) {
            do {
                try fileHandle.seekToEnd()
                try fileHandle.write(contentsOf: data)
            } catch let error {
                print("[MK]: Failed to append [\(self.prefix(128))] to \(fileURL), trying to create new file - \(error.localizedDescription)")
                write(to: fileURL)
            }
        } else {
            fileHandle.seekToEndOfFile()
            fileHandle.write(data)
        }
    }
    
    private func write(to fileURL: URL) {
        do {
            try write(to: fileURL, atomically: true, encoding: .utf8)
        } catch let error {
            print("[MK]: Failed to save [\(self.prefix(128))] to \(fileURL) - \(error.localizedDescription)")
        }
    }
    
}

@objc extension URLSessionConfiguration {
    private static var firstOccurrence = true
    
    static func implementMK() {
        guard firstOccurrence else { return }
        firstOccurrence = false

        // First let's make sure setter: URLSessionConfiguration.protocolClasses is de-duped
        // This ensures MKProtocol won't be added twice
        swizzleProtocolSetter()
        
        // Now, let's make sure MKProtocol is always included in the default and ephemeral configuration(s)
        // Adding it twice won't be an issue anymore, because we've de-duped the setter
        swizzleDefault()
        swizzleEphemeral()
    }
    
    private static func swizzleProtocolSetter() {
        let instance = URLSessionConfiguration.default
        
        let aClass: AnyClass = object_getClass(instance)!
        
        let origSelector = #selector(setter: URLSessionConfiguration.protocolClasses)
        let newSelector = #selector(setter: URLSessionConfiguration.protocolClasses_Swizzled)
        
        let origMethod = class_getInstanceMethod(aClass, origSelector)!
        let newMethod = class_getInstanceMethod(aClass, newSelector)!
        
        method_exchangeImplementations(origMethod, newMethod)
    }
    
    @objc private var protocolClasses_Swizzled: [AnyClass]? {
        get {
            // Unused, but required for compiler
            return self.protocolClasses_Swizzled
        }
        set {
            guard let newTypes = newValue else { self.protocolClasses_Swizzled = nil; return }

            var types = [AnyClass]()
            
            // de-dup
            for newType in newTypes {
                if !types.contains(where: { $0 == newType }) {
                    types.append(newType)
                }
            }
            
            self.protocolClasses_Swizzled = types
        }
    }
    
    private static func swizzleDefault() {
        let aClass: AnyClass = object_getClass(self)!
        
        let origSelector = #selector(getter: URLSessionConfiguration.default)
        let newSelector = #selector(getter: URLSessionConfiguration.default_swizzled)
        
        let origMethod = class_getClassMethod(aClass, origSelector)!
        let newMethod = class_getClassMethod(aClass, newSelector)!
        
        method_exchangeImplementations(origMethod, newMethod)
    }
    
    private static func swizzleEphemeral() {
        let aClass: AnyClass = object_getClass(self)!
        
        let origSelector = #selector(getter: URLSessionConfiguration.ephemeral)
        let newSelector = #selector(getter: URLSessionConfiguration.ephemeral_swizzled)
        
        let origMethod = class_getClassMethod(aClass, origSelector)!
        let newMethod = class_getClassMethod(aClass, newSelector)!
        
        method_exchangeImplementations(origMethod, newMethod)
    }
    
    @objc private class var default_swizzled: URLSessionConfiguration {
        get {
            let config = URLSessionConfiguration.default_swizzled
            
            // Let's go ahead and add in MKProtocol, since it's safe to do so.
            config.protocolClasses?.insert(MKProtocol.self, at: 0)
            
            return config
        }
    }
    
    @objc private class var ephemeral_swizzled: URLSessionConfiguration {
        get {
            let config = URLSessionConfiguration.ephemeral_swizzled
            
            // Let's go ahead and add in MKProtocol, since it's safe to do so.
            config.protocolClasses?.insert(MKProtocol.self, at: 0)
            
            return config
        }
    }
}

#if os(iOS)
extension UIWindow {
    static var keyWindow: UIWindow? {
        if #available(iOS 13.0, *) {
            return UIApplication.shared.connectedScenes
                .sorted { $0.activationState.sortPriority < $1.activationState.sortPriority }
                .compactMap { $0 as? UIWindowScene }
                .compactMap { $0.windows.first { $0.isKeyWindow } }
                .first
        } else {
            return UIApplication.shared.keyWindow
        }
    }
}

@available(iOS 13.0, *)
private extension UIScene.ActivationState {
    var sortPriority: Int {
        switch self {
        case .foregroundActive: return 1
        case .foregroundInactive: return 2
        case .background: return 3
        case .unattached: return 4
        @unknown default: return 5
        }
    }
}
#endif


class Publisher<T> {
    
    private var subscriptions = Set<Subscription<T>>()
    
    var hasSubscribers: Bool { subscriptions.isEmpty == false }
    
    init() where T == Void { }
    
    init() { }
    
    func subscribe(_ subscription: Subscription<T>) {
        subscriptions.insert(subscription)
    }
    
    @discardableResult func subscribe(_ callback: @escaping (T) -> Void) -> Subscription<T> {
        let subscription = Subscription(callback)
        subscriptions.insert(subscription)
        return subscription
    }
    
    func trigger(_ obj: T) {
        subscriptions.forEach {
            if $0.isCancelled {
                unsubscribe($0)
            } else {
                $0.callback(obj)
            }
        }
    }
    
    func unsubscribe(_ subscription: Subscription<T>) {
        subscriptions.remove(subscription)
    }
    
    func unsubscribeAll() {
        subscriptions.removeAll()
    }
    
    func callAsFunction(_ value: T) {
        trigger(value)
    }
    
    func callAsFunction() where T == Void {
        trigger(())
    }
    
}

class Subscription<T>: Equatable, Hashable {
    
    let id = UUID()
    private(set) var isCancelled = false
    fileprivate let callback: (T) -> Void
    
    init(_ callback: @escaping (T) -> Void) {
        self.callback = callback
    }
    
    func cancel() {
        isCancelled = true
    }
    
    static func == (lhs: Subscription<T>, rhs: Subscription<T>) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
}

//
//  MangUtil.swift
//  MangKit_Example
//
//  Created by 邓磊 on 2023/6/13.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit

open class MangUtil: NSObject {
    class var swiftSharedInstance: MangUtil {
        struct Singleton {
            static let instance = MangUtil()
        }
        return Singleton.instance
    }
    
    // the sharedInstance class method can be reached from ObjC
    @objc open class func sharedInstance() -> MangUtil {
        return MangUtil.swiftSharedInstance
    }
    
    func getImage(named name: String, forClass className: AnyClass) -> UIImage? {
        let image = UIImage(named: name, in: self.getBundle(forClass: className), compatibleWith: nil)
        return image
    }
    

    func getBundle(named bundleName: String = "MangKit", forClass className: AnyClass) -> Bundle? {
        let bundlePath = Bundle(for: className).resourceURL?.appendingPathComponent(bundleName + ".bundle")
        if let bundle = bundlePath.flatMap(Bundle.init(url:)) {
            return bundle
        }
        return nil
    }


}

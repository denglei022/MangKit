//
//  MangModuleUtil.swift
//  MangKit
//
//  Created by 邓磊 on 2023/6/12.
//

import UIKit

open class MangModuleUtil {
    // 通用 - 获取InformationModule.framework的Bundle
    static func getFrameworkBundle(_ moduleName: String = "MangKit") -> Bundle? {
        // 先进入MainBundle下的Frameworks文件夹下
        if var bundleURL = Bundle.main.url(forResource: "MangKit", withExtension: nil) {
            // 再进入InformationModule.framework包下
            bundleURL = bundleURL.appendingPathComponent(moduleName)
            bundleURL = bundleURL.appendingPathExtension("framework")
            // 拿到InformationModule.framework的Bundle
            return Bundle(url: bundleURL)
        }
        return nil
    }

    // 获取组件中的图片
    // 组件中的图片在InformationModule.framework下的InformationModuleImageBundle.bundle下
    // 组件中图片在组件项目中的路径是在assets文件夹下
    // 2. 图片没有放在imageset里，imageName直接使用imageName.png
    // 3. 如果放在dou.imageset/里，则imageName传"dou.imageset/dou.png"
    public static func getFrameworkImage(imageName: String, _ resourceBundle: String = "MangKit") -> UIImage? {
        if let informationModuleFrameworkBundle = getFrameworkBundle() {
            // 获取InformationModuleImageBundle.bundle路径
            if let tempBundleURL = informationModuleFrameworkBundle.url(forResource: resourceBundle, withExtension: "bundle") {
                // 获取InformationModuleImageBundle.bundle的Bundle
                let tempBundle = Bundle(url: tempBundleURL)
                // 拿InformationModuleImageBundle.bundle下的头文件
                if let file = tempBundle?.path(forResource: imageName, ofType: nil) {
                    return UIImage(contentsOfFile: file)
                }
            }
        }
        return nil
    }

    // 获取组件中的storyboard
    // 组件中的storyboard在InformationModule.framework下
    public static func getStoryboard(storyboardName: String, _ moduleName: String = "MangKit") -> UIStoryboard? {
        if let informationModuleFrameworkBundle = getFrameworkBundle() {
            return UIStoryboard(name: storyboardName, bundle: informationModuleFrameworkBundle)
        }
        return nil
    }
}


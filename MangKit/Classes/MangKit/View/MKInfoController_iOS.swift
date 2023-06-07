//
//  MKInfoController_iOS.swift
//  AgentBackends
//
//  Created by 邓磊 on 2022/12/16.
//  Copyright © 2022 soudian. All rights reserved.
//

#if os(iOS)

import UIKit

class MKInfoController_iOS: MKInfoController {
    
    var scrollView: UIScrollView = UIScrollView()
    var textLabel: UILabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "信息"
        
        scrollView = UIScrollView()
        scrollView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        scrollView.autoresizesSubviews = true
        scrollView.backgroundColor = UIColor.clear
        view.addSubview(scrollView)
        
        textLabel = UILabel()
        textLabel.frame = CGRect(x: 20, y: 20, width: scrollView.frame.width - 40, height: scrollView.frame.height - 20);
        textLabel.font = UIFont.MKFont(size: 13)
        textLabel.textColor = UIColor.MKGray44Color()
        textLabel.attributedText = generateInfoString("正在获取IP地址..")
        textLabel.numberOfLines = 0
        textLabel.sizeToFit()
        scrollView.addSubview(textLabel)
        
        scrollView.contentSize = CGSize(width: scrollView.frame.width, height: textLabel.frame.maxY)
        
        generateInfo()
    }

    func generateInfo() {
        MKDebugInfo.getMKIP { (result) -> Void in
            DispatchQueue.main.async { () -> Void in
                self.textLabel.attributedText = self.generateInfoString(result)
            }
        }
    }
}

#endif

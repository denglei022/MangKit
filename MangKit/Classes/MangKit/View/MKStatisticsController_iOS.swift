//
//  MKStatisticsController_iOS.swift
//  AgentBackends
//
//  Created by 邓磊 on 2022/12/16.
//  Copyright © 2022 soudian. All rights reserved.
//

#if os(iOS)

import UIKit
    
class MKStatisticsController_iOS: MKStatisticsController {

    private let scrollView: UIScrollView = UIScrollView()
    private let textLabel: UILabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "统计"
        
        scrollView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        scrollView.autoresizesSubviews = true
        scrollView.backgroundColor = UIColor.clear
        view.addSubview(scrollView)
        
        textLabel.frame = CGRect(x: 20, y: 20, width: scrollView.frame.width - 40, height: scrollView.frame.height - 20);
        textLabel.font = UIFont.MKFont(size: 13)
        textLabel.textColor = UIColor.MKGray44Color()
        textLabel.numberOfLines = 0
        textLabel.sizeToFit()
        scrollView.addSubview(textLabel)
        
        scrollView.contentSize = CGSize(width: scrollView.frame.width, height: textLabel.frame.maxY)
    }
    
    override func reloadData() {
        super.reloadData()
        
        textLabel.attributedText = getReportString()
    }
    
}

#endif

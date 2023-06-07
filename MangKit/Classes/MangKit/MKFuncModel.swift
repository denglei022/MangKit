//
//  MKFuncModel.swift
//  AgentBackends
//
//  Created by 邓磊 on 2022/12/21.
//  Copyright © 2022 soudian. All rights reserved.
//

import UIKit

@objc public class MKFuncModel: NSObject {
    @objc public var imageUrl: String?
    @objc public var title: String?
    
    init(imageUrl: String? = nil, title: String? = nil) {
        self.imageUrl = imageUrl
        self.title = title
    }
}

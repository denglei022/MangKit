//
//  MKGenericBodyDetailsController.swift
//  AgentBackends
//
//  Created by 邓磊 on 2022/12/16.
//  Copyright © 2022 soudian. All rights reserved.
//

import Foundation

enum MKBodyType: Int {
    case request  = 0
    case response = 1
}

class MKGenericBodyDetailsController: MKGenericController {
    var bodyType: MKBodyType = MKBodyType.response
}

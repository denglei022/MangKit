//
//  MKSettingsController.swift
//  AgentBackends
//
//  Created by 邓磊 on 2022/12/16.
//  Copyright © 2022 soudian. All rights reserved.
//
    
import Foundation

class MKSettingsController: MKGenericController {
    // MARK: Properties

    let MKVersionString = "MangKit - \(mkVersion)"
    var MKURL = ""
    
    var tableData = [HTTPModelShortType]()
    var filters = MKHTTPModelManager.shared.filters
}

//
//  MKListController.swift
//  AgentBackends
//
//  Created by 邓磊 on 2022/12/16.
//  Copyright © 2022 soudian. All rights reserved.
//

import Foundation


class MKListController: MKGenericController {

    // MARK: - Public Properties
    
    private(set) var tableData = [MKHTTPModel]() {
        didSet {
            reloadData()
        }
    }
    
    private(set) var logData = [String]() {
        didSet {
            reloadData()
        }
    }
    
    var filter: String? = nil {
        didSet {
            filterModels()
        }
    }
    
    // MARK: - Private Properties
    
    private lazy var dataSubscription = Subscription<[MKHTTPModel]> { [weak self] in self?.allModels = $0 }
    
    private lazy var logSubscription = Subscription<[String]> { [weak self] in self?.allLogs = $0 }
    
    private var allModels = [MKHTTPModel]() {
        didSet {
            filterModels()
        }
    }
    
    private var allLogs = [String]() {
        didSet {
            filterModels()
        }
    }
    
    // MARK: - Overloads
    
    deinit {
        dataSubscription.cancel()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        MKHTTPModelManager.shared.publisher.subscribe(dataSubscription)
        populate(with: MKHTTPModelManager.shared.filteredModels)
        
        MKJSModelManager.shared.publisher.subscribe(logSubscription)
        populateLog(with: MKJSModelManager.shared.models)
    }
    
    // MARK: - Public Methods
    
    func populate(with models: [MKHTTPModel]) {
        allModels = models
    }
    
    func populateLog(with logs: [String]) {
        allLogs = logs
    }

    // MARK: - Private Methods
    
    private func filterModels() {
        guard let filter = filter, filter.isEmpty == false else {
            tableData = allModels
            logData = allLogs
            return
        }
        
        tableData = allModels.filter {
            $0.requestURL?.range(of: filter, options: [.caseInsensitive, .diacriticInsensitive]) != nil ||
            $0.requestMethod?.range(of: filter, options: [.caseInsensitive, .diacriticInsensitive]) != nil ||
            $0.responseType?.range(of: filter, options: [.caseInsensitive, .diacriticInsensitive]) != nil
        }
        
        logData = allLogs.filter {
            $0.range(of: filter, options: [.caseInsensitive, .diacriticInsensitive]) != nil
        }
        
    }
    
}

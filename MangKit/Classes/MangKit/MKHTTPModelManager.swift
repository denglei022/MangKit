//
//  MKHTTPModelManager.swift
//  AgentBackends
//
//  Created by 邓磊 on 2022/12/16.
//  Copyright © 2022 soudian. All rights reserved.
//

import Foundation


final class MKHTTPModelManager: NSObject {
    
    static let shared = MKHTTPModelManager()
    
    let publisher = Publisher<[MKHTTPModel]>()
       
    /// Not thread safe. Use only from main thread/queue
    private(set) var models = [MKHTTPModel]() {
        didSet {
            notifySubscribers()
        }
    }
    
    /// Not thread safe. Use only from main thread/queue
    var filters = [Bool](repeating: true, count: HTTPModelShortType.allCases.count) {
        didSet {
            notifySubscribers()
        }
    }
    
    /// Not thread safe. Use only from main thread/queue
    var filteredModels: [MKHTTPModel] {
        let filteredTypes = getCachedFilterTypes()
        return models.filter { filteredTypes.contains($0.shortType) }
    }
    
    /// Thread safe
    func add(_ obj: MKHTTPModel) {
        DispatchQueue.main.async {
            self.models.insert(obj, at: 0)
        }
    }
    
    /// Not thread safe. Use only from main thread/queue
    func clear() {
        models.removeAll()
    }
    
    private func getCachedFilterTypes() -> [HTTPModelShortType] {
        return filters
            .enumerated()
            .compactMap { $1 ? HTTPModelShortType.allCases[$0] : nil }
    }
    
    private func notifySubscribers() {
        if publisher.hasSubscribers {
            publisher(filteredModels)
        }
    }
    
}

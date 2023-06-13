//
//  MKJSModelManager.swift
//  AgentBackends
//
//  Created by 邓磊 on 2023/4/25.
//  Copyright © 2023 soudian. All rights reserved.
//

import UIKit

public class MKJSModelManager: NSObject {
    @objc public static let shared = MKJSModelManager()
    
    let publisher = Publisher<[String]>()
    
    /// Not thread safe. Use only from main thread/queue
    private(set) var models = [String](){
        didSet {
            notifySubscribers()
        }
    }
    
    /// Thread safe
    @objc public func add(_ obj: String) {
        DispatchQueue.main.async {
            self.models.insert(obj, at: 0)
        }
    }
    
    /// Not thread safe. Use only from main thread/queue
    func clear() {
        models.removeAll()
    }
    
    private func notifySubscribers() {
        if publisher.hasSubscribers {
            publisher(models)
        }
    }
}

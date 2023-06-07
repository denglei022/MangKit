//
//  MKURLDetailsController.swift
//  AgentBackends
//
//  Created by 邓磊 on 2022/12/16.
//  Copyright © 2022 soudian. All rights reserved.
//

#if os(iOS)

import Foundation
import UIKit

class MKURLDetailsController: MKDetailsController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "URL Query Strings"
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = true
        
        let tableView: UITableView = UITableView()
        tableView.frame = view.bounds
        tableView.dataSource = self
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(tableView)
    }

}

extension MKURLDetailsController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        if cell == nil {
            cell = UITableViewCell(style: .value1, reuseIdentifier: "cell")
        }
        if let queryItem = selectedModel.requestURLQueryItems?[indexPath.row] {
            cell.textLabel?.text = queryItem.name
            cell.detailTextLabel?.text = queryItem.value
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let queryItems = selectedModel.requestURLQueryItems else {
            return 0
        }
        return queryItems.count
    }
    
}

#endif

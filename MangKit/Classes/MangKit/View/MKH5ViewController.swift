//
//  MKH5ViewController.swift
//  AgentBackends
//
//  Created by 邓磊 on 2023/1/3.
//  Copyright © 2023 soudian. All rights reserved.
//

import UIKit

class MKH5ViewController: UIViewController {

    
    @IBOutlet weak var urlField: UITextField!
    
    @IBOutlet weak var scanBtn: UIButton!
    @IBOutlet weak var confirmBtn: UIButton!
    @IBOutlet weak var historyTableView: UITableView!
    @IBOutlet weak var clearBtn: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "H5任意门"
        
        scanBtn.addTarget(self, action: #selector(MKH5ViewController.MKScanButtonPressed), for: .touchUpInside)
        confirmBtn.addTarget(self, action: #selector(MKH5ViewController.MKURLButtonPressed), for: .touchUpInside)
    }
    
    
    @objc func MKURLButtonPressed() {
        let webVM: DLAllWebViewModel = DLAllWebViewModel.init(services: SDIToolClass.init().BTSharedAppDelegates().services, params: ["BTViewModelRequestKey": self.urlField.text ?? ""])
        let vc : DLAllWebViewController = DLAllWebViewController.init(viewModel: webVM)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func MKScanButtonPressed() {
        let scanVM: SDISScanViewModel = SDISScanViewModel(provider: Application.shared.provider!, params: ["from": "back_result"]) { dic in
            let dic = dic as? NSDictionary
            self.urlField.text = dic?["out_number"] as? String
            self.navigationController?.popViewController(animated: true)
        }
        let vc : SDISScanViewController = SDISScanViewController.init(viewModel: scanVM)
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
}

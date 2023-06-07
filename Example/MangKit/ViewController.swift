//
//  ViewController.swift
//  MangKit
//
//  Created by 邓磊 on 06/07/2023.
//  Copyright (c) 2023 邓磊. All rights reserved.
//

import UIKit
import MangKit
class ViewController: UIViewController, MKMenuFuncDelegate{
    func clearMKCache() {
        
    }
    
    func configEnv() {
        
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        MK.sharedInstance().start()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        MK.sharedInstance().mkMenuDelegate = self
        
    }

}


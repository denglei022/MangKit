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
        self.title = "测试"
        // Do any additional setup after loading the view, typically from a nib.
//        if MK.sharedInstance().isShowLogo(){
        MK.sharedInstance().start()
        MK.sharedInstance().showLogo()
//        if let window = UIApplication.shared.delegate?.window{
//            window?.bringSubviewToFront(MK.sharedInstance().getLogoBtn())
////            window?.sendSubviewToBack(self.view)
//            MK.sharedInstance().mkMenuDelegate = self
//        }
        
        if #available(iOS 14.0, *) {
            if let window = UIApplication.shared.connectedScenes.map({$0 as? UIWindowScene}).compactMap({$0}).first?.windows.first {
                let btn = MK.sharedInstance().getLogoBtn()
                btn.removeFromSuperview()
                window.addSubview(btn)
                window.bringSubviewToFront(btn)
                
            }else if let window = UIApplication.shared.delegate?.window {
                window?.bringSubviewToFront(MK.sharedInstance().getLogoBtn())
            }
        } else if #available(iOS 13.0, *) {
            if let window = UIApplication.shared.connectedScenes.filter({$0.activationState == .foregroundActive}) .map({$0 as? UIWindowScene})
                .compactMap({$0})
                .first?.windows
                .filter({$0.isKeyWindow}).first{
                window.bringSubviewToFront(MK.sharedInstance().getLogoBtn())
            }else if let window = UIApplication.shared.delegate?.window {
                window?.bringSubviewToFront(MK.sharedInstance().getLogoBtn())
            }
        }else{
            if let window = UIApplication.shared.delegate?.window {
                window?.bringSubviewToFront(MK.sharedInstance().getLogoBtn())
            }
        }
//        MK.sharedInstance().show()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}


//
//  MKRawBodyDetailsController.swift
//  AgentBackends
//
//  Created by 邓磊 on 2022/12/16.
//  Copyright © 2022 soudian. All rights reserved.
//

#if os(iOS)

import Foundation
import UIKit

class MKRawBodyDetailsController: MKGenericBodyDetailsController {
    var bodyView: UITextView = UITextView()
    private var copyAlert: UIAlertController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let viewFrame = view.frame
        
        title = "内容详情"
        
        bodyView.frame = CGRect(x: 0, y: 0, width: viewFrame.width, height: viewFrame.height)
        bodyView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        bodyView.backgroundColor = UIColor.clear
        bodyView.textColor = UIColor.MKGray44Color()
		bodyView.textAlignment = .left
        bodyView.isEditable = false
        bodyView.isSelectable = false
        bodyView.font = UIFont.MKFont(size: 13)

        let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(MKRawBodyDetailsController.copyLabel))
        bodyView.addGestureRecognizer(lpgr)
        
        switch bodyType {
            case .request:
            if selectedModel.requestURL?.hasPrefix(MKDetailsController.encryptURL) == true{
                bodyView.text = aesDecryptString(content: selectedModel.getRequestBody())
//                bodyView.text = SDISApiTool().Decrypt(result: selectedModel.getRequestBody()).jsonString(prettify: true)
            }else{
                bodyView.text = selectedModel.getRequestBody() as String
            }
            default:
            if selectedModel.requestURL?.hasPrefix(MKDetailsController.encryptURL) == true{
                bodyView.text = aesDecryptString(content: selectedModel.getRequestBody())
//                bodyView.text =  SDISApiTool().Decrypt(result: selectedModel.getResponseBody()).jsonString(prettify: true)
            }else{
                bodyView.text =  selectedModel.getResponseBody() as String
            }
                
        }
        
        view.addSubview(bodyView)
    }

    @objc fileprivate func copyLabel(lpgr: UILongPressGestureRecognizer) {
        guard let text = (lpgr.view as? UITextView)?.text,
              copyAlert == nil else { return }

        UIPasteboard.general.string = text

        let alert = UIAlertController(title: "已复制!", message: nil, preferredStyle: .alert)
        copyAlert = alert

        present(alert, animated: true) { [weak self] in
            guard let `self` = self else { return }

            Timer.scheduledTimer(timeInterval: 0.45,
                                 target: self,
                                 selector: #selector(MKRawBodyDetailsController.dismissCopyAlert),
                                 userInfo: nil,
                                 repeats: false)
        }
    }

    @objc fileprivate func dismissCopyAlert() {
        copyAlert?.dismiss(animated: true) { [weak self] in self?.copyAlert = nil }
    }
}

#endif

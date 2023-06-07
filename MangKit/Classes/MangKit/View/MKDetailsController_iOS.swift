//
//  MKDetailsController.swift
//  AgentBackends
//
//  Created by 邓磊 on 2022/12/16.
//  Copyright © 2022 soudian. All rights reserved.
//

#if os(iOS)
    
import Foundation
import UIKit
import MessageUI

fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class MKDetailsController_iOS: MKDetailsController, MFMailComposeViewControllerDelegate {
    var infoButton: UIButton = UIButton()
    var requestButton: UIButton = UIButton()
    var responseButton: UIButton = UIButton()

    private var copyAlert: UIAlertController?

    var infoView: UIScrollView = UIScrollView()
    var requestView: UIScrollView = UIScrollView()
    var responseView: UIScrollView = UIScrollView()

    private lazy var headerButtons: [UIButton] = {
        return [self.infoButton, self.requestButton, self.responseButton]
    }()

    private lazy var infoViews: [UIScrollView] = {
        return [self.infoView, self.requestView, self.responseView]
    }()

    internal var sharedContent: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "详情"
        view.layer.masksToBounds = true
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(MKDetailsController_iOS.actionButtonPressed(_:)))

        // Header buttons
        infoButton = createHeaderButton("总览", x: 0, selector: #selector(MKDetailsController_iOS.infoButtonPressed))
        requestButton = createHeaderButton("请求", x: infoButton.frame.maxX, selector: #selector(MKDetailsController_iOS.requestButtonPressed))
        responseButton = createHeaderButton("响应", x: requestButton.frame.maxX, selector: #selector(MKDetailsController_iOS.responseButtonPressed))
        headerButtons.forEach { view.addSubview($0) }

        // Info views
        infoView = createDetailsView(getInfoStringFromObject(selectedModel), forView: .info)
        requestView = createDetailsView(getRequestStringFromObject(selectedModel), forView: .request)
        responseView = createDetailsView(getResponseStringFromObject(selectedModel), forView: .response)
        infoViews.forEach { view.addSubview($0) }

        // Swipe gestures
        let lswgr = UISwipeGestureRecognizer(target: self, action: #selector(MKDetailsController_iOS.handleSwipe(_:)))
        lswgr.direction = .left
        view.addGestureRecognizer(lswgr)

        let rswgr = UISwipeGestureRecognizer(target: self, action: #selector(MKDetailsController_iOS.handleSwipe(_:)))
        rswgr.direction = .right
        view.addGestureRecognizer(rswgr)

        infoButtonPressed()
    }
    
    func createHeaderButton(_ title: String, x: CGFloat, selector: Selector) -> UIButton {
        var tempButton: UIButton
        tempButton = UIButton()
        tempButton.frame = CGRect(x: x, y: 0, width: view.frame.width / 3, height: 44)
        tempButton.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleWidth]
        tempButton.backgroundColor = UIColor.clear
        tempButton.setTitle(title, for: .init())
        tempButton.setTitleColor(UIColor.MKBlackColor(), for: .init())
        tempButton.setTitleColor(UIColor.MKBlueColor(), for: .selected)
        tempButton.titleLabel?.font = UIFont.MKFont(size: 15)
        tempButton.addTarget(self, action: selector, for: .touchUpInside)
        return tempButton
    }

    @objc fileprivate func copyLabel(lpgr: UILongPressGestureRecognizer) {
        guard let text = (lpgr.view as? UILabel)?.text ?? (lpgr.view as? UITextView)?.text,
              copyAlert == nil else { return }

        UIPasteboard.general.string = text

        let alert = UIAlertController(title: "已复制", message: nil, preferredStyle: .alert)
        copyAlert = alert

        present(alert, animated: true) { [weak self] in
            guard let `self` = self else { return }

            Timer.scheduledTimer(timeInterval: 0.45,
                                 target: self,
                                 selector: #selector(MKDetailsController_iOS.dismissCopyAlert),
                                 userInfo: nil,
                                 repeats: false)
        }
    }

    @objc fileprivate func dismissCopyAlert() {
        copyAlert?.dismiss(animated: true) { [weak self] in self?.copyAlert = nil }
    }
    
    func createDetailsView(_ content: NSAttributedString, forView: EDetailsView) -> UIScrollView {
        var scrollView: UIScrollView
        scrollView = UIScrollView()
        scrollView.frame = CGRect(x: 0, y: 44, width: view.frame.width, height: view.frame.height - 44)
        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        scrollView.autoresizesSubviews = true
        scrollView.backgroundColor = UIColor.clear
        
        var textView: UITextView
        textView = UITextView()
        textView.frame = CGRect(x: 20, y: 20, width: scrollView.frame.width - 40, height: scrollView.frame.height - 20);
        textView.backgroundColor = UIColor.clear
        textView.font = UIFont.MKFont(size: 13)
        textView.textColor = UIColor.MKGray44Color()
        textView.isEditable = false
        textView.attributedText = content
        textView.sizeToFit()
        textView.isUserInteractionEnabled = true
        textView.delegate = self
        scrollView.addSubview(textView)

        let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(MKDetailsController_iOS.copyLabel))
        textView.addGestureRecognizer(lpgr)
        
        var moreButton: UIButton
        moreButton = UIButton.init(frame: CGRect(x: 20, y: textView.frame.maxY + 10, width: scrollView.frame.width - 40, height: 40))
        moreButton.backgroundColor = UIColor.MKBlueColor()
        
        if ((forView == EDetailsView.request) && (selectedModel.requestBodyLength > 1024)) {
            moreButton.setTitle("显示请求内容", for: .init())
            moreButton.addTarget(self, action: #selector(MKDetailsController_iOS.requestBodyButtonPressed), for: .touchUpInside)
            scrollView.addSubview(moreButton)
            scrollView.contentSize = CGSize(width: textView.frame.width, height: moreButton.frame.maxY + 16)

        } else if ((forView == EDetailsView.response) && (selectedModel.responseBodyLength > 1024)) {
            moreButton.setTitle("显示响应内容", for: .init())
            moreButton.addTarget(self, action: #selector(MKDetailsController_iOS.responseBodyButtonPressed), for: .touchUpInside)
            scrollView.addSubview(moreButton)
            scrollView.contentSize = CGSize(width: textView.frame.width, height: moreButton.frame.maxY + 16)
            
        } else {
            scrollView.contentSize = CGSize(width: textView.frame.width, height: textView.frame.maxY + 16)
        }
        
        return scrollView
    }
    
    @objc func actionButtonPressed(_ sender: UIBarButtonItem) {
        let actionSheetController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "取消", style: .cancel)
        actionSheetController.addAction(cancelAction)
        
        let simpleLog: UIAlertAction = UIAlertAction(title: "简单日志", style: .default) { [unowned self] action -> Void in
            self.shareLog(full: false, sender: sender)
        }
        actionSheetController.addAction(simpleLog)
        
        let fullLogAction: UIAlertAction = UIAlertAction(title: "完整日志", style: .default) { [unowned self] action -> Void in
            self.shareLog(full: true, sender: sender)
        }
        actionSheetController.addAction(fullLogAction)
        
        if let reqCurl  = selectedModel.requestCurl {
            let curlAction: UIAlertAction = UIAlertAction(title: "导出curl", style: .default) { [unowned self] action -> Void in
                let activityViewController = UIActivityViewController(activityItems: [reqCurl], applicationActivities: nil)
                activityViewController.popoverPresentationController?.barButtonItem = sender
                self.present(activityViewController, animated: true, completion: nil)
            }
            actionSheetController.addAction(curlAction)
        }
        
        actionSheetController.view.tintColor = UIColor.MKOrangeColor()
        actionSheetController.popoverPresentationController?.barButtonItem = sender

        present(actionSheetController, animated: true, completion: nil)
    }
    
    @objc func infoButtonPressed() {
        buttonPressed(infoButton)
    }
    
    @objc func requestButtonPressed() {
        buttonPressed(requestButton)
    }
    
    @objc func responseButtonPressed() {
        buttonPressed(responseButton)
    }

    @objc func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        guard let currentButtonIdx = headerButtons.firstIndex(where: { $0.isSelected }) else { return }
        let numButtons = headerButtons.count

        switch gesture.direction {
            case .left:
                let nextIdx = currentButtonIdx + 1
                buttonPressed(headerButtons[nextIdx > numButtons - 1 ? 0 : nextIdx])
            case .right:
                let previousIdx = currentButtonIdx - 1
                buttonPressed(headerButtons[previousIdx < 0 ? numButtons - 1 : previousIdx])
            default: break
        }
    }
    
    func buttonPressed(_ sender: UIButton) {
        guard let selectedButtonIdx = headerButtons.firstIndex(of: sender) else { return }
        let infoViews = [infoView, requestView, responseView]

        UIView.animate(withDuration: 0.4,
                       delay: 0.0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.7,
                       options: .curveEaseInOut,
                       animations: { [unowned self] in
                            self.headerButtons.indices.forEach {
                                let button = self.headerButtons[$0]
                                let view = infoViews[$0]

                                button.isSelected = button == sender
                                view.frame = CGRect(x: CGFloat(-selectedButtonIdx + $0) * view.frame.size.width,
                                                    y: view.frame.origin.y,
                                                    width: view.frame.size.width,
                                                    height: view.frame.size.height)
                            }
                       },
                       completion: nil)
    }
    
    @objc func responseBodyButtonPressed() {
        bodyButtonPressed().bodyType = MKBodyType.response
    }
    
    @objc func requestBodyButtonPressed() {
        bodyButtonPressed().bodyType = MKBodyType.request
    }
    
    func bodyButtonPressed() -> MKGenericBodyDetailsController {
        
        var bodyDetailsController: MKGenericBodyDetailsController
        
        if selectedModel.shortType == .IMAGE {
            bodyDetailsController = MKImageBodyDetailsController()
        } else {
            bodyDetailsController = MKRawBodyDetailsController()
        }
        bodyDetailsController.selectedModel(selectedModel)
        navigationController?.pushViewController(bodyDetailsController, animated: true)
        return bodyDetailsController
    }
    
    func shareLog(full: Bool, sender: UIBarButtonItem) {
        var tempString = String()

        tempString += "** INFO **\n"
        tempString += "\(getInfoStringFromObject(selectedModel).string)\n\n"

        tempString += "** REQUEST **\n"
        tempString += "\(getRequestStringFromObject(selectedModel).string)\n\n"

        tempString += "** RESPONSE **\n"
        tempString += "\(getResponseStringFromObject(selectedModel).string)\n\n"

        tempString += "logged via \n"

        if full {
            let requestFileURL = selectedModel.getRequestBodyFileURL()
            if let requestFileData = try? String(contentsOf: requestFileURL, encoding: .utf8) {
                tempString += requestFileData
            }

            let responseFileURL = selectedModel.getResponseBodyFileURL()
            if let responseFileData = try? String(contentsOf: responseFileURL, encoding: .utf8) {
                tempString += responseFileData
            }
        }
        
        displayShareSheet(shareContent: tempString, sender: sender)
    }

    func displayShareSheet(shareContent: String, sender: UIBarButtonItem) {
        self.sharedContent = shareContent
        let activityViewController = UIActivityViewController(activityItems: [self], applicationActivities: nil)
        activityViewController.popoverPresentationController?.barButtonItem = sender
        present(activityViewController, animated: true, completion: nil)
    }
}

extension MKDetailsController_iOS: UIActivityItemSource {
    public typealias UIActivityType = UIActivity.ActivityType
    
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return "placeholder"
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivityType?) -> Any? {
        return sharedContent
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivityType?) -> String {
        return "mk log - \(selectedModel.requestURL!)"
    }
}

extension MKDetailsController_iOS: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        let decodedURL = URL.absoluteString.removingPercentEncoding
        switch decodedURL {
        case "[URL]":
            guard let queryItems = selectedModel.requestURLQueryItems, queryItems.count > 0 else {
                return false
            }
            let urlDetailsController = MKURLDetailsController()
            urlDetailsController.selectedModel = selectedModel
            navigationController?.pushViewController(urlDetailsController, animated: true)
            return true
        default:
            return false
        }
    }
    
}

#endif

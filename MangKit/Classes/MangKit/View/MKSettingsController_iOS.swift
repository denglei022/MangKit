//
//  MKSettingsController_iOS.swift
//  AgentBackends
//
//  Created by 邓磊 on 2022/12/16.
//  Copyright © 2022 soudian. All rights reserved.
//

#if os(iOS)
    
import UIKit
import MessageUI

class MKSettingsController_iOS: MKSettingsController, UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate, DataCleaner {
    
    var tableView: UITableView = UITableView(frame: .zero, style: .grouped)
    
    // MARK: View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        MKURL = ""
        
        title = "设置"
        
        tableData = HTTPModelShortType.allCases
        
        edgesForExtendedLayout = UIRectEdge()
        extendedLayoutIncludesOpaqueBars = false
        automaticallyAdjustsScrollViewInsets = false
        
        navigationItem.rightBarButtonItems = [UIBarButtonItem(image: UIImage.MKStatistics(), style: .plain, target: self, action: #selector(MKSettingsController_iOS.statisticsButtonPressed)), UIBarButtonItem(image: UIImage.MKInfo(), style: .plain, target: self, action: #selector(MKSettingsController_iOS.infoButtonPressed))]
        
        tableView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height - 60)
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.translatesAutoresizingMaskIntoConstraints = true
        tableView.delegate = self
        tableView.dataSource = self
        tableView.alwaysBounceVertical = false
        tableView.backgroundColor = UIColor.clear
        tableView.separatorInset = .zero
        
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.tableFooterView?.isHidden = true
        view.addSubview(tableView)
        
        var MKVersionLabel: UILabel
        MKVersionLabel = UILabel(frame: CGRect(x: 10, y: view.frame.height - 60, width: view.frame.width - 2*10, height: 30))
        MKVersionLabel.autoresizingMask = [.flexibleTopMargin, .flexibleWidth]
        MKVersionLabel.font = UIFont.MKFont(size: 14)
        MKVersionLabel.textColor = UIColor.MKOrangeColor()
        MKVersionLabel.textAlignment = .center
        MKVersionLabel.text = MKVersionString
        view.addSubview(MKVersionLabel)
        
        var MKURLButton: UIButton
        MKURLButton = UIButton(frame: CGRect(x: 10, y: view.frame.height - 40, width: view.frame.width - 2*10, height: 30))
        MKURLButton.autoresizingMask = [.flexibleTopMargin, .flexibleWidth]
        MKURLButton.titleLabel?.font = UIFont.MKFont(size: 12)
        MKURLButton.setTitleColor(UIColor.MKGray44Color(), for: .init())
        MKURLButton.titleLabel?.textAlignment = .center
        MKURLButton.setTitle(MKURL, for: .init())
        MKURLButton.addTarget(self, action: #selector(MKSettingsController_iOS.MKURLButtonPressed), for: .touchUpInside)
//        view.addSubview(MKURLButton)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        MKHTTPModelManager.shared.filters = filters
    }
    
    @objc func MKURLButtonPressed() {
        UIApplication.shared.openURL(URL(string: MKURL)!)
    }
    
    @objc func infoButtonPressed() {
        var infoController: MKInfoController_iOS
        infoController = MKInfoController_iOS()
        navigationController?.pushViewController(infoController, animated: true)
    }
    
    @objc func statisticsButtonPressed() {
        var statisticsController: MKStatisticsController_iOS
        statisticsController = MKStatisticsController_iOS()
        navigationController?.pushViewController(statisticsController, animated: true)
    }
    
    // MARK: UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1
        case 1: return 1
        case 2: return self.tableData.count
        case 3: return 1
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.font = UIFont.MKFont(size: 14)
        cell.textLabel?.textColor = .black
        cell.tintColor = UIColor.MKOrangeColor()
        cell.backgroundColor = .white
        
        switch indexPath.section {
        case 0:
            cell.textLabel?.text = "快速过滤后台api请求"
            let MKEnabledSwitch: UISwitch
            MKEnabledSwitch = UISwitch()
            MKEnabledSwitch.setOn(MK.sharedInstance().isFilterd(), animated: false)
            MKEnabledSwitch.addTarget(self, action: #selector(MKSettingsController_iOS.MKIgnoredSwitchValueChanged(_:)), for: .valueChanged)
            cell.accessoryView = MKEnabledSwitch
            return cell
        case 1:
            cell.textLabel?.text = "开启抓包"
            let MKEnabledSwitch: UISwitch
            MKEnabledSwitch = UISwitch()
            MKEnabledSwitch.setOn(MK.sharedInstance().isEnabled(), animated: false)
            MKEnabledSwitch.addTarget(self, action: #selector(MKSettingsController_iOS.MKEnabledSwitchValueChanged(_:)), for: .valueChanged)
            cell.accessoryView = MKEnabledSwitch
            return cell
        case 2:
            let shortType = tableData[indexPath.row]
            cell.textLabel?.text = shortType.rawValue
            configureCell(cell, indexPath: indexPath)
            return cell
            
//        case 2:
//            cell.textLabel?.textAlignment = .center
//            cell.textLabel?.text = "发送请求日志"
//            cell.textLabel?.textColor = UIColor.MKGreenColor()
//            cell.textLabel?.font = UIFont.MKFont(size: 16)
//            return cell
//
        case 3:
            cell.textLabel?.textAlignment = .center
            cell.textLabel?.text = "清理缓存"
            cell.textLabel?.textColor = UIColor.MKRedColor()
            cell.textLabel?.font = UIFont.MKFont(size: 16)
            
            return cell
            
        default: return UITableViewCell()

        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.MKGray95Color()
        
        
        switch section {
        case 2:
            var filtersInfoLabel: UILabel
            filtersInfoLabel = UILabel(frame: headerView.bounds)
            filtersInfoLabel.backgroundColor = UIColor.clear
            filtersInfoLabel.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            filtersInfoLabel.font = UIFont.MKFont(size: 13)
            filtersInfoLabel.textColor = UIColor.MKGray44Color()
            filtersInfoLabel.textAlignment = .center
            filtersInfoLabel.text = "\n勾选你想抓取的Response类型"
            filtersInfoLabel.numberOfLines = 2
            headerView.addSubview(filtersInfoLabel)
            
            
        default: break
        }
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 1:
            let cell = tableView.cellForRow(at: indexPath)
            self.filters[indexPath.row] = !self.filters[indexPath.row]
            configureCell(cell, indexPath: indexPath)
//        case 2:
//            shareSessionLogsPressed()
        case 2:
            clearDataButtonPressedOnTableIndex(indexPath)
        default:
            break
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0,1: return 44
        case 2: return 33
        case 3: return 44
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return 20
        case 2:
            return 60
        case 3:
            return 50
        default: return 0
        }
    }
    
    func configureCell(_ cell: UITableViewCell?, indexPath: IndexPath) {
        cell?.accessoryType = filters[indexPath.row] ? .checkmark : .none
    }
    
    @objc func MKEnabledSwitchValueChanged(_ sender: UISwitch) {
        if sender.isOn {
//            MK.sharedInstance().enable()
            MKSessionConfiguration.default.startMonitor()
        } else {
//            MK.sharedInstance().disable()
            MKSessionConfiguration.default.stopMonitor()
        }
    }
    
    @objc func MKIgnoredSwitchValueChanged(_ sender: UISwitch) {
        if sender.isOn {
            MK.sharedInstance().filter()
            MK.sharedInstance().ignoreURLsWithRegex("^((?!/api).)*$")
            MK.sharedInstance().ignoreURLsWithRegex(".*sentry.*")
        } else {
            MK.sharedInstance().disableFilter()
            MK.sharedInstance().removeIgnoreURLsRegexes()
        }
    }
    
    func clearDataButtonPressedOnTableIndex(_ index: IndexPath) {
        clearData(sourceView: tableView, originingIn: tableView.rectForRow(at: index)) { }
    }

    func shareSessionLogsPressed() {
        if (MFMailComposeViewController.canSendMail()) {
            let mailComposer = MFMailComposeViewController()
            mailComposer.mailComposeDelegate = self
            
            mailComposer.setSubject("mk log - Session Log \(NSDate())")
            if let sessionLogData = try? Data(contentsOf: MKPath.sessionLogURL) {
                mailComposer.addAttachmentData(sessionLogData as Data, mimeType: "text/plain", fileName: MKPath.sessionLogName)
            }
            
            present(mailComposer, animated: true, completion: nil)
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        dismiss(animated: true, completion: nil)
    }
}

#endif

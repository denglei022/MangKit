//
//  MKJSBridgeListViewController.swift
//  AgentBackends
//
//  Created by 邓磊 on 2023/4/21.
//  Copyright © 2023 soudian. All rights reserved.
//

import UIKit

class MKJSBridgeListViewController: MKListController, UITableViewDataSource , UITableViewDelegate, UISearchResultsUpdating, UISearchControllerDelegate, DataCleaner{
   
    
    private var copyAlert: UIAlertController?
    // MARK: Properties
    
    var tableView = UITableView(frame: .zero, style: .grouped)
    var searchController: UISearchController!
    
    // MARK: View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "JS交互日志"
        
        edgesForExtendedLayout = UIRectEdge.all
        extendedLayoutIncludesOpaqueBars = true
        automaticallyAdjustsScrollViewInsets = false
        tableView.frame = self.view.frame
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.translatesAutoresizingMaskIntoConstraints = true
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .white
        tableView.separatorInset = .zero
        view.addSubview(self.tableView)
        
        tableView.register(UINib(nibName: "MKListTableViewCell", bundle: nil), forCellReuseIdentifier: NSStringFromClass(MKListTableViewCell.self))

//        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage.MKClose(), style: .plain, target: self, action: #selector(MKListController_iOS.closeButtonPressed))

        let rightButtons = [
            UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(MKJSBridgeListViewController.trashButtonPressed))
        ]

        self.navigationItem.rightBarButtonItems = rightButtons

        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.delegate = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.autoresizingMask = [.flexibleWidth]
        searchController.searchBar.backgroundColor = UIColor.clear
        searchController.searchBar.barTintColor = UIColor.MKOrangeColor()
        searchController.searchBar.tintColor = UIColor.MKOrangeColor()
        searchController.searchBar.searchBarStyle = .minimal
        searchController.view.backgroundColor = UIColor.clear
        
        if #available(iOS 11.0, *) {
            navigationItem.searchController = searchController
            definesPresentationContext = true
        } else {
            let searchView = UIView()
            searchView.frame = CGRect(x: 0, y: 0, width: view.frame.width - 60, height: 0)
            searchView.autoresizingMask = [.flexibleWidth]
            searchView.autoresizesSubviews = true
            searchView.backgroundColor = UIColor.clear
            searchView.addSubview(searchController.searchBar)
            searchController.searchBar.sizeToFit()
            searchView.frame = searchController.searchBar.frame

            navigationItem.titleView = searchView
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        reloadData()
    }
    
    @objc func settingsButtonPressed() {
        var settingsController: MKSettingsController_iOS
        settingsController = MKSettingsController_iOS()
        navigationController?.pushViewController(settingsController, animated: true)
    }

    @objc func trashButtonPressed() {
        clearLog(sourceView: tableView, originingIn: nil) { [weak self] in
            self?.reloadData()
        }
    }

    // MARK: UISearchResultsUpdating
    
    func updateSearchResults(for searchController: UISearchController) {
        filter = searchController.searchBar.text
    }
    
    override func reloadData() {
        self.tableView.reloadData()
    }

    // MARK: UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.logData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
            ?? UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
        cell.selectionStyle = .none
        cell.textLabel?.text = logData[indexPath.row]
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.font = UIFont.systemFont(ofSize: 14)
        return cell
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView(frame: .zero)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        UIPasteboard.general.string = logData[indexPath.row]

        let alert = UIAlertController(title: "已复制!", message: nil, preferredStyle: .alert)
        copyAlert = alert

        present(alert, animated: true) { [weak self] in
            guard let `self` = self else { return }

            Timer.scheduledTimer(timeInterval: 0.45,
                                 target: self,
                                 selector: #selector(MKJSBridgeListViewController.dismissCopyAlert),
                                 userInfo: nil,
                                 repeats: false)
        }
    }
    
    @objc fileprivate func dismissCopyAlert() {
        copyAlert?.dismiss(animated: true) { [weak self] in self?.copyAlert = nil }
    }
}

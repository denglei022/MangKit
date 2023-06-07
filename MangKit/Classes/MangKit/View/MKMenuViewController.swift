//
//  MKMenuViewController.swift
//  AgentBackends
//
//  Created by 邓磊 on 2022/12/20.
//  Copyright © 2022 soudian. All rights reserved.
//

import UIKit

class MKMenuViewController: MKViewController {
 
    @IBOutlet weak var myCollectionView: UICollectionView!
    @IBOutlet weak var closeSwitch: UISwitch!
    var list = [MKFuncModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Mang Kit"
        // Do any additional setup after loading the view.
        
        myCollectionView.delegate = self;
        myCollectionView.dataSource = self;

        myCollectionView.register(UINib(nibName: "MKMenuCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: NSStringFromClass(MKMenuCollectionViewCell.self))
        myCollectionView.register(UINib(nibName: "MKMenuCollectionReusableView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: NSStringFromClass(MKMenuCollectionReusableView.self))
        
        self.initData()
        myCollectionView.reloadData()
        
        
        closeSwitch.setOn(UserDefaults.standard.bool(forKey: "isShowLogo"), animated: false)
        closeSwitch.addTarget(self, action: #selector(MKMenuViewController.MKCloseSwitchValueChanged(_:)), for: .valueChanged)
        
        
    }
    
    func initData(){
        
        let model1 = MKFuncModel(imageUrl: "icon_mk_debug", title: "网络抓包")
        let model2 = MKFuncModel(imageUrl: "icon_mk_network", title: "环境切换")
        let model3 = MKFuncModel(imageUrl: "icon_mk_H5", title: "H5任意门")
        let model4 = MKFuncModel(imageUrl: "icon_mk_log", title: "日志")
        let model5 = MKFuncModel(imageUrl: "icon_mk_clear", title: "清除缓存")
        list.append(model1)
        list.append(model2)
        list.append(model3)
        list.append(model4)
        list.append(model5)
    }
    
    @objc func MKCloseSwitchValueChanged(_ sender: UISwitch) {
        if sender.isOn {
            MK.sharedInstance().showLogo()
        } else {
            MK.sharedInstance().hideLogo()
        }
    }
}

extension MKMenuViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: NSStringFromClass(MKMenuCollectionReusableView.self), for: indexPath)
        return view
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSizeMake(view.width, 40)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSizeMake(self.view.width / 4 - 10, 80)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.list.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: MKMenuCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(MKMenuCollectionViewCell.self), for: indexPath) as! MKMenuCollectionViewCell
        cell.configForObject(self.list[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let model = self.list[indexPath.row]
        switch (model.title){
        case "网络抓包":
            self.navigationController?.pushViewController(MKListController_iOS(), animated: true)
        case "环境切换":
            let vc = SDIConfigEnvViewController.init(viewModel: SDIConfigEnvViewModel.init(services: SDIToolClass().BTSharedAppDelegates().services, params: nil))
            self.navigationController?.pushViewController(vc!)
        case "H5任意门":
            self.navigationController?.pushViewController(MKH5ViewController(), animated: true)
            break
        case "日志":
            self.navigationController?.pushViewController(MKJSBridgeListViewController(), animated: true)
            break
        case "清除缓存":
            DLCommenHelper.clearWebCache()
            SDISDefaults[.h5Version] = "0"
            //预下载h5更新包
            let viewModel = SDIDownloadH5ViewModel.init(services: SDIToolClass().BTSharedAppDelegates().services!, params: nil)
            viewModel?.getOnlineH5VersionCommand.execute(nil)
            let sdImageCache = SDImageCache.shared
            sdImageCache.clearMemory()
            sdImageCache.clearDisk {
                MBProgressHUD.showSuccess("缓存已清理", to: nil)
            }
            break
        default:
            break
        }
    }
}

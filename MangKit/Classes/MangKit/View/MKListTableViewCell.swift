//
//  MKListTableViewCell.swift
//  AgentBackends
//
//  Created by 邓磊 on 2022/12/19.
//  Copyright © 2022 soudian. All rights reserved.
//

import UIKit

class MKListTableViewCell: UITableViewCell {

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var duringLabel: UILabel!
    @IBOutlet weak var urlLabel: UILabel!
    @IBOutlet weak var methodLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet weak var contentTypeLabel: UILabel!

    @IBOutlet weak var timeView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configForObject(_ obj: MKHTTPModel) {
        self.timeLabel.text = obj.requestTime
        self.duringLabel.text = "\(String(format:"%.2f",obj.timeInterval ?? 0.0))"
        self.urlLabel.text = obj.requestURL
        self.methodLabel.text = obj.requestMethod
        self.statusLabel.text = "\(obj.responseStatus ?? 0)"
        var length =  "\(String(format:"%.2f",obj.responseBodyLength ?? 0.0))b"
        if obj.responseBodyLength ?? 0 > 1024{
            length = "\("\(String(format:"%.2f",(obj.responseBodyLength?.float ?? 0.0)/1024.0))")kb"
        }
        self.sizeLabel.text = length
        self.contentTypeLabel.text =  obj.requestType
        
        if obj.responseStatus == 200{
            timeView.backgroundColor = UIColor.MKGreenColor() //green
            duringLabel.textColor = UIColor.MKDarkGreenColor()
        }else{
            timeView.backgroundColor = UIColor.MKRedColor() //red
            duringLabel.textColor = UIColor.MKDarkRedColor()
        }
    }
}

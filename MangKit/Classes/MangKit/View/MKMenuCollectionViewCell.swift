//
//  MKMenuCollectionViewCell.swift
//  AgentBackends
//
//  Created by 邓磊 on 2022/12/20.
//  Copyright © 2022 soudian. All rights reserved.
//

import UIKit

class MKMenuCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleImageView: UIImageView!
   
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configForObject(_ obj: MKFuncModel) {
        self.titleLabel.text = obj.title
        self.titleImageView.image = UIImage(named: obj.imageUrl ?? "")
    }
}

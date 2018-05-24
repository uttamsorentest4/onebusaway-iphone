//
//  StopCell.swift
//  OneBusAway
//
//  Created by Aaron Brethorst on 5/23/18.
//  Copyright © 2018 OneBusAway. All rights reserved.
//

import UIKit
import OBAKit
import SnapKit

class StopCell: SelfSizingCollectionCell {
    var stopViewModel: StopViewModel? {
        didSet {
            guard let stop = stopViewModel else {
                return
            }
            label.text = stop.nameWithDirection
        }
    }

    fileprivate let label = UILabel.init()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white

        contentView.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(SelfSizingCollectionCell.insets)
        }
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

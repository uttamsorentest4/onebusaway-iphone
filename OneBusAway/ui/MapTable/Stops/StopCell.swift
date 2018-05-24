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

    fileprivate let label: UILabel = {
        let lbl = UILabel.init()
        lbl.backgroundColor = .white

        return lbl
    }()


    let separator: CALayer = {
        let layer = CALayer()
        layer.backgroundColor = UIColor(red: 200 / 255.0, green: 199 / 255.0, blue: 204 / 255.0, alpha: 1).cgColor
        return layer
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = OBATheme.mapTableBackgroundColor

        let plainWrapper = label.oba_embedInWrapper()
        let cardWrapper = plainWrapper.oba_embedInCardWrapper()

        label.snp.updateConstraints { (make) in
            make.height.greaterThanOrEqualTo(44)
        }

        contentView.addSubview(cardWrapper)
        cardWrapper.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsetsMake(0, OBATheme.defaultPadding, 0, OBATheme.defaultPadding))
        }

//        wrapper.snp.makeConstraints { (make) in
//            make.edges.equalToSuperview().inset(SelfSizingCollectionCell.insets).inset(UIEdgeInsetsMake(0, OBATheme.defaultPadding, 0, OBATheme.defaultPadding))
//            make.height.greaterThanOrEqualTo(44.0)
//        }

        contentView.layer.addSublayer(separator)

//        label.backgroundColor = .magenta
//        plainWrapper.backgroundColor = .yellow
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let bounds = contentView.bounds
        let height: CGFloat = 0.5
        let sideInset = OBATheme.defaultEdgeInsets.left
        separator.frame = CGRect(x: sideInset, y: bounds.height - height, width: bounds.width - (2 * sideInset), height: height)
    }


    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

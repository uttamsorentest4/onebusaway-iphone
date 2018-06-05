//
//  RegionalAlertSection.swift
//  OneBusAway
//
//  Created by Aaron Brethorst on 6/4/18.
//  Copyright © 2018 OneBusAway. All rights reserved.
//

import Foundation
import IGListKit
import OBAKit

class RegionalAlertCell: UICollectionViewCell {
    let titleLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }

        backgroundColor = .clear
        contentView.backgroundColor = .clear
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - Data Loading

    var alert: OBARegionalAlert? {
        didSet {
            guard let alert = alert else {
                return
            }
            titleLabel.text = alert.title
        }
    }
}

class RegionalAlertSectionController: ListSectionController {
    var data: OBARegionalAlert?

    override init() {
        super.init()
        inset = UIEdgeInsets(top: 0, left: 0, bottom: 30, right: 0)
    }

    override func sizeForItem(at index: Int) -> CGSize {
        return CGSize(width: collectionContext!.containerSize.width, height: 55)
    }

    override func cellForItem(at index: Int) -> UICollectionViewCell {
        guard
            let ctx = collectionContext,
            let data = data,
            let cell = ctx.dequeueReusableCell(of: RegionalAlertCell.self, for: self, at: index) as? RegionalAlertCell
            else {
                fatalError()
        }
        cell.alert = data

        return cell
    }

    override func didUpdate(to object: Any) {
        precondition(object is OBARegionalAlert)
        data = object as? OBARegionalAlert
    }
}


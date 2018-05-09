//
//  MapTableListAdapter.swift
//  OneBusAway
//
//  Created by Aaron Brethorst on 5/8/18.
//  Copyright © 2018 OneBusAway. All rights reserved.
//

import UIKit
import IGListKit

class MapTableListAdapter: NSObject, ListAdapterDataSource {
    var adapter: ListAdapter
    weak var collectionView: UICollectionView?

    init(viewController: UIViewController, collectionView: UICollectionView) {
        adapter = ListAdapter(updater: ListAdapterUpdater(), viewController: viewController, workingRangeSize: 1)

        super.init()

        adapter.collectionView = collectionView
        adapter.dataSource = self
    }

    let data = [128, 256, 64]

    // MARK: ListAdapterDataSource

    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        return data as [ListDiffable]
    }

    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        // note that each child section controller is designed to handle an Int (or no data)
        let sectionController = ListStackedSectionController(sectionControllers: [
            WorkingRangeSectionController(),
            DisplaySectionController(),
            HorizontalSectionController()
            ])
        sectionController.inset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        return sectionController
    }

    func emptyView(for listAdapter: ListAdapter) -> UIView? { return nil }


}

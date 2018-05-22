//
//  ForecastSectionController.swift
//  OneBusAway
//
//  Created by Aaron Brethorst on 5/21/18.
//  Copyright © 2018 OneBusAway. All rights reserved.
//

import IGListKit
import UIKit

class ForecastSectionController: ListSectionController, ListDisplayDelegate {
    var data: WeatherForecast?

    override init() {
        super.init()
        displayDelegate = self
        inset = UIEdgeInsets(top: 0, left: 0, bottom: 30, right: 0)
    }

    override func sizeForItem(at index: Int) -> CGSize {
        return CGSize(width: collectionContext!.containerSize.width, height: 55)
    }

    override func cellForItem(at index: Int) -> UICollectionViewCell {
        guard
            let ctx = collectionContext,
            let data = data,
            let cell = ctx.dequeueReusableCell(of: LabelCell.self, for: self, at: index) as? LabelCell
            else {
                fatalError()
        }

        cell.text = "\(data.currentTemperature) - \(data.currentSummary)"
        return cell
    }

    override func didUpdate(to object: Any) {
        precondition(object is WeatherForecast)
        data = object as? WeatherForecast
    }

    // MARK: - ListDisplayDelegate

    func listAdapter(_ listAdapter: ListAdapter, willDisplay sectionController: ListSectionController) {
        print("Will display section \(self.section)")
    }

    func listAdapter(_ listAdapter: ListAdapter,
                     willDisplay sectionController: ListSectionController,
                     cell: UICollectionViewCell,
                     at index: Int) {
        print("Did will display cell \(index) in section \(self.section)")
    }

    func listAdapter(_ listAdapter: ListAdapter, didEndDisplaying sectionController: ListSectionController) {
        print("Did end displaying section \(self.section)")
    }

    func listAdapter(_ listAdapter: ListAdapter,
                     didEndDisplaying sectionController: ListSectionController,
                     cell: UICollectionViewCell,
                     at index: Int) {
        print("Did end displaying cell \(index) in section \(self.section)")
    }

}

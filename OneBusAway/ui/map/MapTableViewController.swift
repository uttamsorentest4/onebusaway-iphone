//
//  MapTableViewController.swift
//  OneBusAway
//
//  Created by Aaron Brethorst on 4/29/18.
//  Copyright © 2018 OneBusAway. All rights reserved.
//

import UIKit
import MapKit

class MapTableViewController: UIViewController {

    lazy var tableView: UITableView = {
        let table = UITableView.init(frame: self.view.bounds)
        table.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        table.dataSource = self
        table.delegate = self
        table.backgroundView = mapView
        table.contentInset = UIEdgeInsetsMake(320, 0, 0, 0)
        table.showsVerticalScrollIndicator = false
        table.tableFooterView = UIView.init()
        return table
    }()

    lazy var mapView: MKMapView = {
        let map = MKMapView.init(frame: view.bounds)
        map.register(MKPinAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        map.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        map.delegate = self
        return map
    }()

    var mapDataLoader: OBAMapDataLoader
    var mapRegionManager: OBAMapRegionManager

    init(mapDataLoader: OBAMapDataLoader, mapRegionManager: OBAMapRegionManager) {
        self.mapDataLoader = mapDataLoader
        self.mapRegionManager = mapRegionManager

        super.init(nibName: nil, bundle: nil)

        self.mapDataLoader.add(self)
        self.mapRegionManager.add(delegate: self)

        self.title = NSLocalizedString("msg_map", comment: "Map tab title")
        self.tabBarItem.image = UIImage.init(named: "Map")
        self.tabBarItem.selectedImage = UIImage.init(named: "Map_Selected")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: NSStringFromClass(UITableViewCell.self))
        view.addSubview(tableView)
    }
}

extension MapTableViewController: OBAMapDataLoaderDelegate {
    func mapDataLoaderFinishedUpdating(_ mapDataLoader: OBAMapDataLoader) {
        //
    }

    func mapDataLoader(_ mapDataLoader: OBAMapDataLoader, didReceiveError error: Error) {
        //
    }

    func mapDataLoader(_ mapDataLoader: OBAMapDataLoader, didUpdate searchResult: OBASearchResult) {
        //
    }

    func mapDataLoader(_ mapDataLoader: OBAMapDataLoader, startedUpdatingWith target: OBANavigationTarget) {
        //
    }
}

extension MapTableViewController: OBAMapRegionDelegate {
    func mapRegionManager(_ manager: OBAMapRegionManager, setRegion region: MKCoordinateRegion, animated: Bool) {
        //
    }
}

extension MapTableViewController: OBANavigationTargetAware {
    func navigationTarget() -> OBANavigationTarget {
        if mapDataLoader.searchType == .region {
            return OBANavigationTarget.init(forSearchLocationRegion: mapView.region)
        }
        else {
            return mapDataLoader.searchTarget
        }
    }
}

extension MapTableViewController: MKMapViewDelegate {
    public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {

        if annotation.isKind(of: MKUserLocation.self) {
            return nil
        }

        let view = mapView.dequeueReusableAnnotationView(withIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier, for: annotation)

        return view
    }
}

extension MapTableViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(UITableViewCell.self), for: indexPath)
        cell.textLabel?.text = "Row \(indexPath.row + 1)"
        return cell
    }
}

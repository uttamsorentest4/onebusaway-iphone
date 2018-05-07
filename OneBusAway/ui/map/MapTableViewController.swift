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

    private let identifier = "CellIdentifier"

    private lazy var layout: UICollectionViewFlowLayout = {
        let flowLayout = UICollectionViewFlowLayout.init()
        return flowLayout
    }()

    private lazy var collectionView: UICollectionView = {
        let coll = UICollectionView.init(frame: view.bounds, collectionViewLayout: layout)
        coll.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        coll.dataSource = self
        coll.delegate = self
        coll.backgroundView = mapContainer
        coll.contentInset = UIEdgeInsetsMake(320, 0, 0, 0)
        coll.showsVerticalScrollIndicator = false
        coll.backgroundColor = OBATheme.mapTableBackgroundColor
        return coll
    }()

    private lazy var mapContainer: UIView = {
        let view = UIView.init(frame: self.view.bounds)
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.backgroundColor = UIColor.magenta //OBATheme.mapTableBackgroundColor
        return view
    }()

    private var stops: [OBAStopV2] = []

    var mapController: OBAMapViewController

    var application: OBAApplication
    var locationManager: OBALocationManager
    var mapDataLoader: OBAMapDataLoader
    var mapRegionManager: OBAMapRegionManager
    var modelDAO: OBAModelDAO

    init(application: OBAApplication) {
        self.application = application
        self.locationManager = application.locationManager
        self.mapDataLoader = application.mapDataLoader
        self.mapRegionManager = application.mapRegionManager
        self.modelDAO = application.modelDao

        self.mapController = OBAMapViewController.init(mapDataLoader: self.mapDataLoader, mapRegionManager: self.mapRegionManager)
        self.mapController.standaloneMode = false

        super.init(nibName: nil, bundle: nil)

        self.mapDataLoader.add(self)
        self.mapRegionManager.add(delegate: self)

        self.title = NSLocalizedString("msg_map", comment: "Map tab title")
        self.tabBarItem.image = UIImage.init(named: "Map")
        self.tabBarItem.selectedImage = UIImage.init(named: "Map_Selected")
    }

    deinit {
        self.mapDataLoader.cancelOpenConnections()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        oba_addChildViewController(mapController, to: mapContainer)

        registerCells(with: collectionView)
        view.addSubview(collectionView)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        refreshCurrentLocation()
    }
}

// MARK: - Scroll Delegate
extension MapTableViewController : UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // TODO.
    }
}

// MARK: - Location Management
extension MapTableViewController {
    private func refreshCurrentLocation() {
        if let location = locationManager.currentLocation {
            if mapRegionManager.lastRegionChangeWasProgrammatic {
                let radius = max(location.horizontalAccuracy, OBAMinMapRadiusInMeters)
                let region = OBASphericalGeometryLibrary.createRegion(withCenter: location.coordinate, latRadius: radius, lonRadius: radius)
                mapRegionManager.setRegion(region, changeWasProgrammatic: true)
            }
        }
        else if let region = modelDAO.currentRegion {
            let coordinateRegion = MKCoordinateRegionForMapRect(region.serviceRect)
            mapRegionManager.setRegion(coordinateRegion, changeWasProgrammatic: true)
        }
    }
}

// MARK: - Map Data Loader
extension MapTableViewController: OBAMapDataLoaderDelegate {
    func mapDataLoaderFinishedUpdating(_ mapDataLoader: OBAMapDataLoader) {
        //
    }

    func mapDataLoader(_ mapDataLoader: OBAMapDataLoader, didReceiveError error: Error) {
        //
    }

    func mapDataLoader(_ mapDataLoader: OBAMapDataLoader, didUpdate searchResult: OBASearchResult) {
        self.stops = searchResult.values.filter { $0 is OBAStopV2 } as! [OBAStopV2]
        reloadData()
    }

    func mapDataLoader(_ mapDataLoader: OBAMapDataLoader, startedUpdatingWith target: OBANavigationTarget) {
        //
    }
}

// MARK: - Map Region Delegate
extension MapTableViewController: OBAMapRegionDelegate {
    func mapRegionManager(_ manager: OBAMapRegionManager, setRegion region: MKCoordinateRegion, animated: Bool) {
        //
    }
}

// MARK: - Navigation Target Aware
extension MapTableViewController: OBANavigationTargetAware {
    func navigationTarget() -> OBANavigationTarget {
        return mapDataLoader.searchTarget
//        if mapDataLoader.searchType == .region {
//            return OBANavigationTarget.init(forSearchLocationRegion: mapView.region)
//        }
//        else {
//            return mapDataLoader.searchTarget
//        }
    }
}

// MARK: - Map Delegate
extension MapTableViewController: MKMapViewDelegate {
    public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {

        if annotation.isKind(of: MKUserLocation.self) {
            return nil
        }

        let view = mapView.dequeueReusableAnnotationView(withIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier, for: annotation)

        return view
    }
}

// MARK: - Data Loading
extension MapTableViewController {
    func reloadData() {
        collectionView.reloadData()
    }
}

// MARK: - Collection View
extension MapTableViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    class CollectionViewCell: UICollectionViewCell {
        let textLabel = UILabel.init()

        override init(frame: CGRect) {
            super.init(frame: frame)

            contentView.backgroundColor = UIColor.white

            textLabel.frame = contentView.bounds
            textLabel.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            contentView.addSubview(textLabel)
        }

        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }

    func registerCells(with collectionView: UICollectionView) {
        collectionView.register(CollectionViewCell.self, forCellWithReuseIdentifier: identifier)
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return stops.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! CollectionViewCell
        let stop = self.stops[indexPath.item]

        cell.textLabel.text = stop.nameWithDirection

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let stop = self.stops[indexPath.item]

        let stopController = OBAStopViewController.init(stopID: stop.stopId)
        self.navigationController?.pushViewController(stopController, animated: true)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 44)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

}

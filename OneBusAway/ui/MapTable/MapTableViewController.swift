//
//  MapTableViewController.swift
//  OneBusAway
//
//  Created by Aaron Brethorst on 4/29/18.
//  Copyright © 2018 OneBusAway. All rights reserved.
//

import UIKit
import IGListKit
import MapKit

// https://stackoverflow.com/a/26299473
class PassthroughCollectionView: UICollectionView {
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let height = bounds.height + contentOffset.y
        let collectionBounds = CGRect.init(x: 0, y: 0, width: bounds.width, height: height)
        return collectionBounds.contains(point)
    }
}

class MapTableViewController: UIViewController {

    // MARK: - IGListKit/Collection
    lazy var adapter: ListAdapter = {
        return ListAdapter(updater: ListAdapterUpdater(), viewController: self, workingRangeSize: 1)
    }()

    let collectionView: PassthroughCollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.estimatedItemSize = CGSize(width: 375, height: 40)
        let collectionView = PassthroughCollectionView(frame: .zero, collectionViewLayout: layout)
        return collectionView
    }()

    var stops: [OBAStopV2]? {
        didSet {
            adapter.performUpdates(animated: false)
        }
    }

    var centerCoordinate: CLLocationCoordinate2D?

    var application: OBAApplication
    var locationManager: OBALocationManager
    var mapDataLoader: OBAMapDataLoader
    var mapRegionManager: OBAMapRegionManager
    var modelDAO: OBAModelDAO
    let modelService: PromisedModelService

    // MARK: - Weather
    var weatherForecast: WeatherForecast? {
        didSet {
            self.adapter.performUpdates(animated: true, completion: nil)
        }
    }

    // MARK: - Map Controller

    private lazy var mapContainer: UIView = {
        let view = UIView.init(frame: self.view.bounds)
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.backgroundColor = OBATheme.mapTableBackgroundColor
        return view
    }()

    private var mapController: OBAMapViewController

    // MARK: - Init

    init(application: OBAApplication) {
        self.application = application
        self.locationManager = application.locationManager
        self.mapDataLoader = application.mapDataLoader
        self.mapRegionManager = application.mapRegionManager
        self.modelDAO = application.modelDao
        self.modelService = application.modelService

        self.mapController = OBAMapViewController.init(mapDataLoader: application.mapDataLoader, mapRegionManager: application.mapRegionManager)
        self.mapController.standaloneMode = false

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

    deinit {
        self.mapDataLoader.cancelOpenConnections()
    }
}

// MARK: - UIViewController
extension MapTableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        oba_addChildViewController(mapController, to: mapContainer)
        mapContainer.frame = view.bounds
        mapContainer.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapContainer)

        collectionView.backgroundColor = .clear

        collectionView.contentInset = UIEdgeInsetsMake(Sweep.defaultHeight + 100, 0, 0, 0)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.alwaysBounceVertical = true

        view.addSubview(collectionView)
        adapter.collectionView = collectionView
        adapter.dataSource = self
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        refreshCurrentLocation()
        loadForecast()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = CGRect.init(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height + Sweep.defaultHeight)
    }
}

// MARK: - Weather
extension MapTableViewController {
    fileprivate func loadForecast() {
        guard let region = modelDAO.currentRegion else {
            return
        }

        let wrapper = modelService.requestWeather(in: region, location: self.locationManager.currentLocation)
        wrapper.promise.then { networkResponse -> Void in
            let forecast = networkResponse.object as! WeatherForecast
            self.weatherForecast = forecast
        }.catch { error in
            DDLogError("Unable to retrieve regional alerts: \(error)")
        }
    }
}

// MARK: - ListAdapterDataSource
extension MapTableViewController: ListAdapterDataSource {
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        guard application.isServerReachable else {
            return [OfflineSection(), Sweep()]
        }

        var sections: [ListDiffable] = []

        // Forecast

        if let forecast = weatherForecast {
            sections.append(forecast)
        }

        // Recent Stops
        let recentNearbyStops = buildNearbyRecentStopViewModels()
        if recentNearbyStops.count > 0 {
            sections.append(SectionHeader(text: NSLocalizedString("map_search.recent_stops_section_title", comment: "Recent Stops")))
            sections.append(contentsOf: recentNearbyStops)
        }

        // Nearby Stops

        if stops == nil {
            sections.append(LoadingSection())
        }
        else {
            sections.append(SectionHeader(text: NSLocalizedString("msg_nearby_stops", comment: "Nearby Stops text")))

            let stopViewModels: [StopViewModel] = stops!.map {
                StopViewModel.init(name: $0.name, stopID: $0.stopId, direction: $0.direction, routeNames: $0.routeNamesAsString())
            }
            sections.append(contentsOf: stopViewModels)
        }

        // Bottom Sweep

        sections.append(Sweep())

        return sections
    }

    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        let sectionController = createSectionController(for: object)
        sectionController.inset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        return sectionController
    }

    func emptyView(for listAdapter: ListAdapter) -> UIView? { return nil }

    private func createSectionController(for object: Any) -> ListSectionController {
        switch object {
        case is LoadingSection: return LoadingSectionController()
        case is OfflineSection: return OfflineSectionController()
        case is SectionHeader: return SectionHeaderSectionController()
        case is StopViewModel: return StopSectionController()
        case is Sweep: return BottomSweepSectionController()
        case is WeatherForecast: return ForecastSectionController()
        default:
            fatalError()
        }
    }

    private func buildNearbyRecentStopViewModels(pick upTo: Int = 2) -> [StopViewModel] {
        guard let centerCoordinate = centerCoordinate else {
            return []
        }

        let nearbyRecentStops: [OBAStopAccessEventV2] = modelDAO.recentStopsNearCoordinate(centerCoordinate)
        guard nearbyRecentStops.count > 0 else {
            return []
        }

        let viewModels: [StopViewModel] = nearbyRecentStops.map {
            StopViewModel.init(name: $0.title, stopID: $0.stopID, direction: "DIR_TBD", routeNames: $0.subtitle)
        }

        return Array(viewModels.prefix(upTo))
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
    func mapDataLoader(_ mapDataLoader: OBAMapDataLoader, didUpdate searchResult: OBASearchResult) {
        let unsortedStops = searchResult.values.filter { $0 is OBAStopV2 } as! [OBAStopV2]
        stops = sort(stops: unsortedStops, byDistanceTo: centerCoordinate)
    }

    // TODO: DRY me up with identical function in NearbyStopsViewController
    fileprivate func sort(stops: [OBAStopV2], byDistanceTo coordinate: CLLocationCoordinate2D?) -> [OBAStopV2] {
        guard let coordinate = coordinate else {
            return stops
        }

        return stops.sorted { (s1, s2) -> Bool in
            let distance1 = OBAMapHelpers.getDistanceFrom(s1.coordinate, to: coordinate)
            let distance2 = OBAMapHelpers.getDistanceFrom(s2.coordinate, to: coordinate)
            return distance1 < distance2
        }
    }
}

// MARK: - Map Region Delegate
extension MapTableViewController: OBAMapRegionDelegate {
    func mapRegionManager(_ manager: OBAMapRegionManager, setRegion region: MKCoordinateRegion, animated: Bool) {
        self.centerCoordinate = region.center
    }
}

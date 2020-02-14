//
//  ViewController.swift
//  GameStopApp
//
//  Created by mcs on 2/9/20.
//  Copyright © 2020 MCS. All rights reserved.
//

import MapKit
import YelpAPI
import UIKit
import os.log
import FirebaseCrashlytics

struct State {
    static var tempBusiness: YLPBusiness?
}

public class ViewController: UIViewController, CLLocationManagerDelegate {
    
    private var businesses = [YLPBusiness]()
    private let client = YLPClient(apiKey: YelpAPIKey)
    let locationManager = CLLocationManager()
    var newCoordinate = CLLocationCoordinate2D()
    @IBOutlet weak var currentSearch: UITextField!
    @IBOutlet weak var mapSearch: UISearchBar!
    @IBOutlet weak var textSearchButton: UIButton!
    @IBOutlet weak var mapView: MKMapView! {
        didSet {
            mapView.showsUserLocation = true
        }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.locationManager.requestWhenInUseAuthorization()
        mapSearch.delegate = self
        currentSearch.delegate = self
        mapView.delegate = self
        textSearchButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }
}
extension ViewController: UISearchBarDelegate {
    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let searchText = searchBar.text ?? "GameStop"
        searchForBusinesses(searchString: searchText)
    }
}

extension ViewController: MKMapViewDelegate, UITextFieldDelegate {
    
    public func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        centerMap(on: userLocation.coordinate)
    }
    
    @objc public func buttonTapped() {
        let address = currentSearch.text ?? ""
        let temp = CLLocationCoordinate2DMake(34.0, 84.0)
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(address) { (placemarks, error) in
            self.newCoordinate = placemarks?.first?.location?.coordinate ?? temp
        self.centerMap(on: self.newCoordinate)
        }
    }
    
    public func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        for business in businesses {
            if business.location.coordinate?.latitude == mapView.selectedAnnotations[0].coordinate.latitude && business.location.coordinate?.longitude == mapView.selectedAnnotations[0].coordinate.longitude{
                State.tempBusiness = business
            }
        }
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ReView") as? ReVIEW
        self.navigationController?.pushViewController(vc ?? ViewController(), animated: true)
    }
    
    private func centerMap(on coordinate: CLLocationCoordinate2D) {
        let regionRadius: CLLocationDistance = 3000
        let point = MKMapPoint(coordinate)
        let mapSize = MKMapSize(width: 3000.0, height: 3000.0)
        let map = MKMapRect(origin: point, size: mapSize)
        let coordinateRegion = MKCoordinateRegion(center: coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
        mapView.setVisibleMapRect(map, animated: true)
    }
    
    private func searchForBusinesses(searchString: String) {
        self.mapView.removeAnnotations(self.mapView.annotations)
        let coordinate = mapView.centerCoordinate
        let yelpCoordinate = YLPCoordinate(latitude: coordinate.latitude, longitude: coordinate.longitude)
        client.search(with: yelpCoordinate, term: searchString, limit: 35, offset: 0, sort: .bestMatched) {
            [weak self] (searchResult, error) in
            guard let strongSelf = self else { return }
            guard let searchResult = searchResult, error == nil
                else {
                    print("Search failed: \(String(describing: error))")
                    return
            }
            
            strongSelf.businesses = searchResult.businesses
            DispatchQueue.main.async {
                strongSelf.addAnnotations()
            }
        }
    }
    
    private func addAnnotations() {
        for business in businesses {
            guard let yelpCoordinate = business.location.coordinate else {
                continue
            }
            guard let imageURL = business.imageURL else {
                continue
            }
            let coordinate = CLLocationCoordinate2D(latitude: yelpCoordinate.latitude, longitude: yelpCoordinate.longitude)
            let name = business.name
            let rating = business.rating
            let id = business.identifier
            let annotation = MainViewModel(id: id, coordinate: coordinate, name: name, rating: rating, imageURL: imageURL)
            
            mapView.addAnnotation(annotation)
        }
    }
}


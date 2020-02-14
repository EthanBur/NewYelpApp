//
//  MainViewModel.swift
//  GameStopApp
//
//  Created by mcs on 2/9/20.
//  Copyright © 2020 MCS. All rights reserved.
//

import Foundation
import MapKit

public class MainViewModel: NSObject {
  
    public let coordinate: CLLocationCoordinate2D
    public let name: String
    public let rating: Double
    public let imageURL: URL
    public let id: String
    
    public init(id: String, coordinate: CLLocationCoordinate2D, name: String, rating: Double, imageURL: URL) {
        self.id = id
        self.coordinate = coordinate
        self.name = name
        self.rating = rating
        self.imageURL = imageURL
    }
    
}

extension MainViewModel: MKAnnotation {
  
  public var title: String? {
    return name
  }
}

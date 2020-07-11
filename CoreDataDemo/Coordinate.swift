//
//  Coordinate.swift
//  CoreDataDemo
//
//  Created by Crocodic-MBP5 on 06/07/20.
//  Copyright © 2020 Crocodic Studio. All rights reserved.
//

import Foundation

public class Coordinates: NSObject, NSCoding {
    public var coordinates = [Coordinate]()
    
    override init() {
        
    }
    
    public func encode(with coder: NSCoder) {
        coder.encode(coordinates, forKey: "coordinates")
    }
    
    public required init?(coder: NSCoder) {
        coordinates = coder.decodeObject(forKey: "coordinates") as? [Coordinate] ?? []
    }
}

public class Coordinate: NSObject, NSCoding {
    public var latitude = Double()
    public var longitude = Double()
    
    init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
    
    public func encode(with coder: NSCoder) {
        coder.encode(latitude, forKey: "latitude")
        coder.encode(longitude, forKey: "longitude")
    }
    
    public required init?(coder: NSCoder) {
        latitude = coder.decodeDouble(forKey: "latitude")
        longitude = coder.decodeDouble(forKey: "longitude")
    }
    
    
}

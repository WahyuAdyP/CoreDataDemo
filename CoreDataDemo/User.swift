//
//  User.swift
//  CoreDataDemo
//
//  Created by Crocodic-MBP5 on 02/07/20.
//  Copyright © 2020 Crocodic Studio. All rights reserved.
//

import Foundation
import CoreData
import UIKit

public class User: Object {
    @NSManaged var id: Int
    @NSManaged var address: String
    @NSManaged var nama: String
    @NSManaged var image: UIImage?
    @NSManaged var coordinates: Coordinates?
    
    public override func awakeFromInit() {
        id = User.incrementId()
    }
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    static func incrementId() -> Int {
        return (DatabaseHelper.shared.getData(objectType: User.self, sortBy: "id", ascending: false)?.id ?? 0) + 1
    }
}

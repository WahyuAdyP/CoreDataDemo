//
//  Object.swift
//  CoreDataDemo
//
//  Created by Crocodic-MBP5 on 10/07/20.
//  Copyright © 2020 Crocodic Studio. All rights reserved.
//

import Foundation
import CoreData
import UIKit

public class Object: NSManagedObject {
    required override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
        
    }
    
    convenience init() {
        let stack = CoreDataStack()
        let context = stack.managedObjectContext
        let className = String(describing: type(of: self))
        
        self.init(entity: NSEntityDescription.entity(forEntityName: className, in: context)!, insertInto: nil)

        awakeFromInit()
    }
    
    public func awakeFromInit() {
        
    }
    
    class func primaryKey() -> String? {
        return nil
    }
}


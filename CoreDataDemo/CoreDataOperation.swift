//
//  Object.swift
//  ReprimeApps
//
//  Created by Crocodic-MBP5 on 01/07/20.
//  Copyright © 2020 Crocodic. All rights reserved.
//

import Foundation
import CoreData

class CoreDataOperation {
    private var stack: CoreDataStack
    private var context: NSManagedObjectContext
    private var model: NSManagedObjectModel
    
    // MARK: - Initialize
    init() {
        stack = CoreDataStack()
        context = stack.managedObjectContext
        model = stack.managedObjectModel
    }
    
    // MARK: - Read
    func objects<T: Object>(_ objectType: T.Type, filter predicate: NSPredicate? = nil, sorted sort: [NSSortDescriptor]? = nil) -> [T] {
        let className = String(describing: objectType)

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: className)
        request.predicate = predicate
        request.sortDescriptors = sort

        do {
            let results = try context.fetch(request) as? [T]
            return results ?? []
        } catch let error {
            print(error.localizedDescription)
            
            return []
        }
    }
    
    func objects<T: Object>(_ objectType: T.Type, filter predicate: NSPredicate? = nil, sortBy key: String? = nil, ascending: Bool? = nil) -> [T] {
        var sort: [NSSortDescriptor]?
        if let bool = ascending {
            sort = [NSSortDescriptor(key: key, ascending: bool)]
        }
        return objects(objectType, filter: predicate, sorted: sort)
    }
    
    func object<T: Object>(ofType objectType: T.Type, forPrimaryKey primaryValue: Any) -> T? {
        if let primaryKey = objectType.primaryKey() {
            let predicateFormat = "\(primaryKey) = \(primaryValue)"
            let predicate = NSPredicate(format: predicateFormat)
            return objects(objectType, filter: predicate).first
        } else {
            fatalError("Class not conforms primary key")
        }
    }
    
    // MARK: - Create & Update
    func add<T: Object>(_ object: T, update: Bool = false) -> Bool {
        let className = String(describing: type(of: object))
        let entityDescription = NSEntityDescription.entity(forEntityName: className, in: context)

        if update {
            if let primaryKey = type(of: object).primaryKey(), let primaryValue = object.value(forKey: primaryKey) {
                let result = self.object(ofType: type(of: object), forPrimaryKey: primaryValue)
                if result != nil {
                    result?.entity.attributesByName.keys.forEach { (key) in
                        result?.setValue(object.value(forKey: key), forKey: key)
                    }
                } else {
                    let data = T(entity: entityDescription!, insertInto: context)
                    data.entity.attributesByName.keys.forEach { (key) in
                        data.setValue(object.value(forKey: key), forKey: key)
                    }
                }
            } else {
                fatalError("Primary key not set")
            }
        } else {
            print("Not update")
            let data = T(entity: entityDescription!, insertInto: context)
            data.entity.attributesByName.keys.forEach { (key) in
                data.setValue(object.value(forKey: key), forKey: key)
            }
        }

        do {
            try context.save()
            return true
        } catch let error {
            print(error.localizedDescription)
            return false
        }
    }
    
    func add<T: Object>(_ datas: [T], update: Bool = false) -> Bool {
        for data in datas {
            let isAdded = add(data, update: update)
            if !isAdded {
                return false
            }
        }
        return true
    }
    
    // MARK: - Delete
    func delete<T: Object>(_ object: T) -> Bool {
        context.delete(object)
        
        do {
            try context.save()
            return true
        } catch let error {
            print(error.localizedDescription)
            return false
        }
    }
    
    func delete<T: Object>(_ datas: [T]) -> Bool {
        for data in datas {
            let isDeleted = delete(data)
            if !isDeleted {
                return false
            }
        }
        return true
    }
    
    func deleteAll() -> Bool {
        let entities = model.entities
        for entity in entities {
            guard let entityName = entity.name else { continue }
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            
            do {
                try context.execute(deleteRequest)
            } catch let error {
                print(error.localizedDescription)
                return false
            }
        }
        
        return true
    }
}

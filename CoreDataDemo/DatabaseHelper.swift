//
//  DatabaseHelper.swift
//  ReprimeApps
//
//  Created by Crocodic MBP-2 on 4/27/18.
//  Copyright © 2018 Crocodic. All rights reserved.
//

import Foundation
import CoreData

class DatabaseHelper {
    static let shared: DatabaseHelper = DatabaseHelper()
    
    typealias Results<T> = [T]
    
    // Function comment because lib not yet loaded
    var operation: CoreDataOperation!

    // MARK: - Initialization
    init() {
        self.operation = CoreDataOperation()

        do {
            try self.initDefaultValues()
        } catch let error {
            print("Error initialization default value \(error.localizedDescription)")
        }

    }

    // MARK: - Functions
    func initDefaultValues() throws {
        
    }

    func checkData<T: Object>(objectType: T.Type, filter predicate: NSPredicate) -> Bool {
        return self.operation.objects(objectType, filter: predicate).first != nil
    }

    func getData<T: Object>(objectType: T.Type) -> T? {
        return self.operation.objects(objectType).first
    }

    func getData<T: Object>(objectType: T.Type, filter predicate: NSPredicate) -> T? {
        return self.operation.objects(objectType, filter: predicate).first
    }

    func getData<T: Object>(objectType: T.Type, key: Any) -> T? {
        let obj = self.operation.object(ofType: objectType, forPrimaryKey: key)
        return obj
    }

    func getData<T: Object>(objectType: T.Type, sortBy property: String, ascending: Bool = true) -> T? {
        return self.operation.objects(objectType, sortBy: property, ascending: ascending).first
    }

    func getData<T: Object>(objectType: T.Type, filter predicate: NSPredicate, sortBy property: String, ascending: Bool = true) -> T? {
        return self.operation.objects(objectType, filter: predicate, sortBy: property, ascending: ascending).first
    }

    func getAllData<T: Object>(objectType: T.Type) -> Results<T> {
        return self.operation.objects(objectType)
    }

    func getAllData<T: Object>(objectType: T.Type, filter predicate: NSPredicate) -> Results<T> {
        return self.operation.objects(objectType, filter: predicate)
    }

    func getAllData<T: Object>(objectType: T.Type, sortBy property: String, ascending: Bool) -> Results<T> {
        return self.operation.objects(objectType, sortBy: property, ascending: ascending)
    }

    func getAllData<T: Object>(objectType: T.Type, filter predicate: NSPredicate, sortBy property: String, ascending: Bool = true) -> Results<T> {
        return self.operation.objects(objectType, filter: predicate, sortBy: property, ascending: ascending)
    }

    func getAllData<T: Object>(objectType: T.Type, sortBy property: [NSSortDescriptor]) -> Results<T> {
        return self.operation.objects(objectType, sorted: property)
    }

    func getAllData<T: Object>(objectType: T.Type, filter predicate: NSPredicate, sortBy property: [NSSortDescriptor]) -> Results<T> {
        return self.operation.objects(objectType, filter: predicate, sorted: property)
    }

    func addData(object: Object, update: Bool = true) -> Bool {
        return operation.add(object, update: update)
    }

    func addData(objects: [Object], update: Bool = true) -> Bool {
        return operation.add(objects, update: update)
    }

    func deleteData(object: Object) -> Bool {
        return operation.delete(object)
    }

    func deleteData(objects: [Object]) -> Bool {
        return operation.delete(objects)
    }

    func deleteAllData<T: Object>(objectType: T.Type) -> Bool {
        return operation.delete(operation.objects(objectType))
    }
    
    func deleteAllData() -> Bool {
        return operation.deleteAll()
    }
}

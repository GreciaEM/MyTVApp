//
//  CoreData.swift
//  MyTVApp
//
//  Created by Grecia Escárcega on 13/09/20.
//  Copyright © 2020 GEM. All rights reserved.
//

import CoreData

final class CoreDataStack {
 
    static let shared = CoreDataStack()
    var errorHandler: (Error) -> Void = {_ in }
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "MyTVApp")
        container.loadPersistentStores(completionHandler: { [weak self] (storeDescription, error) in
            if let error = error {
                self?.errorHandler(error)
            }
            })
        return container
    }()
    
    lazy var viewContext: NSManagedObjectContext = {
        return self.persistentContainer.viewContext
    }()
}

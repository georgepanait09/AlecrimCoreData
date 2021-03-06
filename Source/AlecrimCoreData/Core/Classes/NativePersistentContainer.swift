//
//  NativePersistentContainer.swift
//  AlecrimCoreData
//
//  Created by Vanderlei Martinelli on 2016-10-14.
//  Copyright © 2016 Alecrim. All rights reserved.
//

import Foundation
import CoreData

// MARK: -

@available(iOS 10.0, *) // to make tools happy
@available(macOSApplicationExtension 10.12, iOSApplicationExtension 10.0, tvOSApplicationExtension 10.0, watchOSApplicationExtension 3.0, *)
internal class NativePersistentContainer: NSPersistentContainer, UnderlyingPersistentContainer {
    
    private let contextType: NSManagedObjectContext.Type
    private let _viewContext: NSManagedObjectContext
    private let _masterViewContext: NSManagedObjectContext
    
    internal override var viewContext: NSManagedObjectContext { return self._viewContext }
    internal var masterViewContext: NSManagedObjectContext { return self._masterViewContext }
    
    internal required init(name: String, managedObjectModel model: NSManagedObjectModel, contextType: NSManagedObjectContext.Type) {
        self.contextType = contextType
        
        self._masterViewContext = self.contextType.init(concurrencyType: .privateQueueConcurrencyType)
        self._viewContext = self.contextType.init(concurrencyType: .mainQueueConcurrencyType)
        
        super.init(name: name, managedObjectModel: model)
        
        self._masterViewContext.persistentStoreCoordinator = self.persistentStoreCoordinator
        self._viewContext.parent = self._masterViewContext
       
        //self._viewContext.automaticallyMergesChangesFromParent = true
        self._viewContext.undoManager = nil
        self._viewContext.shouldDeleteInaccessibleFaults = true
        
        self._viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        self._masterViewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
    internal override func newBackgroundContext() -> NSManagedObjectContext {
        let context = self.contextType.init(concurrencyType: .privateQueueConcurrencyType)
        
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        context.parent = self.viewContext
        context.automaticallyMergesChangesFromParent = true
        context.undoManager = nil
        context.shouldDeleteInaccessibleFaults = true
        return context
    }
    
    @available(*, unavailable)
    internal override func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
        fatalError()
    }
    
    internal var alc_persistentStoreDescriptions: [PersistentStoreDescription] {
        get { return self.persistentStoreDescriptions }
        set {
            guard let newValue = newValue as? [NSPersistentStoreDescription] else {
                fatalError("Unexpected persistent store description type.")
            }
            
            self.persistentStoreDescriptions = newValue
        }
    }
    
    internal func alc_loadPersistentStores(completionHandler block: @escaping (PersistentStoreDescription, Error?) -> Void) {
        self.loadPersistentStores(completionHandler: block)
    }
    
    internal func configureDefaults(for context: NSManagedObjectContext) {
        //        context.automaticallyMergesChangesFromParent = true
        //        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
}

// MARK: -

@available(iOS 10.0, *) // to make tools happy
@available(macOSApplicationExtension 10.12, iOSApplicationExtension 10.0, tvOSApplicationExtension 10.0, watchOSApplicationExtension 3.0, *)
extension NSPersistentStoreDescription: PersistentStoreDescription {
    
}

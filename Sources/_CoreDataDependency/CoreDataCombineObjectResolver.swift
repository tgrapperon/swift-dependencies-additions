//
//  CoreDataCombineObjectResolver.swift
//  swift-dependencies-additions
//
//  Created by Robert Nash on 12/09/2025.
//

import CoreData
import Combine

/// Resolves Core Data objects from their `NSManagedObjectID`s and publishes updates.
public final class CoreDataCombineObjectResolver<T: NSManagedObject> {
    
    private let idsSubject = CurrentValueSubject<[NSManagedObjectID], Never>([])
    public let publisher: AnyPublisher<[T], Never>
    
    private let context: NSManagedObjectContext
    private var cancellables = Set<AnyCancellable>()
    
    public init(
        context: NSManagedObjectContext,
        deliverOn: DispatchQueue = .main,
        debounce: DispatchQueue.SchedulerTimeType.Stride? = nil,
        sortDescriptors: [NSSortDescriptor]? = nil
    ) {
        self.context = context
        
        var publisher: AnyPublisher<[NSManagedObjectID], Never> = idsSubject
            .removeDuplicates(by: { lhs, rhs in
                lhs.count == rhs.count && lhs.elementsEqual(rhs, by: { $0 == $1 })
            })
            .eraseToAnyPublisher()
        
        if let d = debounce {
            publisher = publisher
                .debounce(for: d, scheduler: deliverOn)
                .eraseToAnyPublisher()
        }
        
        self.publisher = publisher
            .flatMap { ids -> AnyPublisher<[T], Never> in
                Deferred {
                    Future { promise in
                        context.perform {
                            do {
                                guard let entityName = T.entity().name else {
                                    promise(.success([])); return
                                }
                                let request = NSFetchRequest<T>(entityName: entityName)
                                request.predicate = NSPredicate(format: "SELF IN %@", Array(ids))
                                request.sortDescriptors = sortDescriptors
                                
                                let results = try context.fetch(request)
                                promise(.success(results))
                            } catch {
                                promise(.success([]))
                            }
                        }
                    }
                }
                .eraseToAnyPublisher()
            }
            .receive(on: deliverOn)
            .eraseToAnyPublisher()
    }
    
    public func resolve(_ ids: [NSManagedObjectID]) {
        idsSubject.send(ids)
    }
}

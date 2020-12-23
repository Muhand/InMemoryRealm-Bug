//
//  InMemoryRealmCache.swift
//  InMemoryRealm
//
//  Created by Muhand Jumah on 12/22/20.
//

import RealmSwift

struct Sorted {
    var key: String
    var ascending: Bool = true
}

protocol Cachable {}

protocol InMemoryCache {
    func create<T: Cachable>(model: T.Type,
                             _ completion: @escaping (Result<T, Error>) -> ())
    
    func save(object: Cachable,
              _ completion: @escaping (Result<Void, Error>) -> ())
    
    func fetch<T: Cachable>(model: T.Type,
                            predicate: NSPredicate?,
                            sorted: Sorted?,
                            _ completion: @escaping (Result<[T], Error>) -> ())
}
    

enum RealmInMemoryCacheError: Error {
    case notRealmSpecificModel
    case realmIsNil
    case realmError
}


final class RealmInMemoryCache {

    private let configuration: Realm.Configuration
    private let queue: DispatchQueue

    init(_ configuration: Realm.Configuration) {
        self.queue = DispatchQueue(label: "inMemoryRealm", qos: .utility)
        self.configuration = configuration
    }
}

extension RealmInMemoryCache : InMemoryCache{
    func create<T>(model: T.Type,
                   _ completion: @escaping (Result<T, Error>) -> ()) where T : Cachable {
        self.queue.async {
            guard let realm = try? Realm(configuration: self.configuration) else {
                completion(.failure(RealmInMemoryCacheError.realmIsNil))
                return
            }
            
            guard let model = model as? RealmSwift.Object.Type else {
                completion(.failure(RealmInMemoryCacheError.notRealmSpecificModel))
                return
            }
        
        
            do {
                try realm.write { () -> () in
                    let newObject = realm.create(model, value: [], update: .all) as! T
                    completion(.success(newObject))
                    return
                }
            } catch {
                completion(.failure(RealmInMemoryCacheError.realmError))
                return
             }
        }
    }
    
    func save(object: Cachable,
              _ completion: @escaping (Result<Void, Error>) -> ()) {
        self.queue.async {
            guard let realm = try? Realm(configuration: self.configuration) else {
                completion(.failure(RealmInMemoryCacheError.realmIsNil))
                return
            }
            
            guard let object = object as? RealmSwift.Object else {
                completion(.failure(RealmInMemoryCacheError.notRealmSpecificModel))
                return
            }
        
        
            do {
                try realm.write { () -> () in
                    realm.add(object, update: .all)
                    completion(.success(()))
                    return
                }
            } catch {
                completion(.failure(RealmInMemoryCacheError.realmError))
                return
            }
        }
    }
    
    func fetch<T>(model: T.Type,
                  predicate: NSPredicate?,
                  sorted: Sorted?,
                  _ completion: @escaping (Result<[T], Error>) -> ()) where T : Cachable {
        self.queue.async {
            guard let realm = try? Realm(configuration: self.configuration) else {
                completion(.failure(RealmInMemoryCacheError.realmIsNil))
                return
            }
            
            guard
                let model = model as? RealmSwift.Object.Type else {
                completion(.failure(RealmInMemoryCacheError.notRealmSpecificModel))
                return
            }
            
            
            var objects = realm.objects(model)
            
            if let predicate = predicate {
                objects = objects.filter(predicate)
            }

            if let sorted = sorted {
                objects = objects.sorted(byKeyPath: sorted.key, ascending: sorted.ascending)
            }

            completion(.success(objects.compactMap { $0 as? T}))
            return
        }
    }
}

extension Object: Cachable {}

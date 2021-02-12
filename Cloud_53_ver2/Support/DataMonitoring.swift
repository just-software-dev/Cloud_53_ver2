//
//  DataMonitoring.swift
//  Cloud 53
//
//  Created by Андрей on 06.08.2020.
//  Copyright © 2020 oak. All rights reserved.
//

import FirebaseDatabase
import FirebaseStorage

class DataMonitoring {
    
    static let shareInstance = DataMonitoring()
    
    private let ref = Database.database().reference()
    private let storageRef = Storage.storage().reference()
    private var observers: [(handle: UInt, path: String)] = []
    
    func observe(path: String, completion: @escaping (DataSnapshot) -> Void) {
        let handle = ref.child(path).observe(.value, with: completion)
        observers.append((handle: handle, path: path))
    }
    
    func set(path: String, value: Any, completion: ((Error?, DatabaseReference) -> Void)? = nil) {
        if let completion = completion {
            ref.child(path).setValue(value, withCompletionBlock: completion)
        } else {
            ref.child(path).setValue(value)
        }
    }
    
    func get(path: String, completion: @escaping (DataSnapshot) -> Void) {
        ref.child(path).observeSingleEvent(of: .value, with: completion)
    }
    
    func removeObservers(path: String? = nil) {
        if let path = path {
            for e in observers {
                if e.path == path {
                    ref.child(e.path).removeObserver(withHandle: e.handle)
                }
            }
            return
        } else {
            for e in observers {
                ref.child(e.path).removeObserver(withHandle: e.handle)
            }
        }
        observers = []
    }
    
    func downloadImage(path: String, completion: @escaping (Data?, Error?) -> Void) {
        storageRef.child(path).getData(maxSize: .max, completion: completion)
    }
}

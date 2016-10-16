//
//  Threadsafe.swift
//  Pods
//
//  Created by Hakon Hanesand on 10/15/16.
//
//

import Foundation

internal class Threadsafe<T> {
    
    private let accessQueue = DispatchQueue(label: "no.abello.Image.threadsafeaccess", qos: .userInitiated)
    
    private var internal_contents: T
    
    public var contents: T {
        get {
            var value: T? = nil
            
            accessQueue.sync {
                value = self.internal_contents
            }
            
            return value!
        }
        
        set {
            accessQueue.sync {
                self.internal_contents = newValue
            }
        }
    }
    
    init(_ contents: T) {
        self.internal_contents = contents
    }
}

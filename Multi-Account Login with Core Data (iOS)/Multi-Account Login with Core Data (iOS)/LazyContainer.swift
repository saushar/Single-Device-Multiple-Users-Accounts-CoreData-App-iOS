//
//  LazyContainer.swift
//  Multi-Account Login with Core Data (iOS)
//
//  Created by SAURABH SHARMA on 11/12/20.
//  Copyright © 2020 SAURABH SHARMA. All rights reserved.
//

import Foundation

class LazyContainer<T> {
    private var t: T?
    private var constructor: (String) -> T
    
    init(_ constructor: @escaping (String) -> T) {
        self.constructor = constructor
    }
    
    func get(string: String) -> T {
        if t == nil {
            t = constructor(string)
        }
        return t!
    }
    
    func clear() {
        t = nil
    }
}

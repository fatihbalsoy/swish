//
//  File.swift
//  
//
//  Created by Fatih Balsoy on 2/19/20.
//

import Foundation

class BashStorage {
    private var variables = [String:String]()
    
    func get() -> [String : String] {
        variables["RANDOM"] = String(Int.random(in: 0 ..< 32767))
        return variables
    }
    func set(from: [String:String]) {
        for set in from {
            variables[set.key] = set.value
        }
    }
    func set(_ value: String, for key: String) {
        variables[key] = value
    }
    func removeAll() {
        variables.removeAll()
    }
    func removeValue(forKey: String) {
        variables.removeValue(forKey: forKey)
    }
}

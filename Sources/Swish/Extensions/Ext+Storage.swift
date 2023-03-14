//
//  File.swift
//  
//
//  Created by Fatih Balsoy on 2/19/20.
//

import Foundation

public class BashStorage {
    private var variables = [String:String]()
    
    public func get() -> [String : String] {
        variables["RANDOM"] = String(Int.random(in: 0 ..< 32767))
        return variables
    }
    public func set(from: [String:String]) {
        for set in from {
            variables[set.key] = set.value
        }
    }
    public func set(_ value: String, for key: String) {
        variables[key] = value
    }
    public func removeAll() {
        variables.removeAll()
    }
    public func removeValue(forKey: String) {
        variables.removeValue(forKey: forKey)
    }
}

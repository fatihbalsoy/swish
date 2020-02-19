//
//  Extensions.swift
//  
//
//  Created by Fatih Balsoy on 2/19/20.
//

import Foundation

extension Array where Element == String.SubSequence {
    func get(_ index: Int) -> String.SubSequence {
        return self.get(index) ?? Substring("")
    }
}

extension Array where Element: Equatable {    
    func get(_ index: Int) -> Element? {
        if self.indices.contains(index) {
            return self[index]
        } else {
            return nil
        }
    }
}

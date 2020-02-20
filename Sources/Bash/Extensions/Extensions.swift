//
//  Extensions.swift
//  
//
//  Created by Fatih Balsoy on 2/19/20.
//

import Foundation

extension Array where Element == StandardStream {
    mutating func appendOutput(_ exit: Int, _ output: String) {
        self.append(StandardStream(exitCode: exit, stream: output))
    }
}

extension Array where Element == String.SubSequence {
    func get(_ index: Int) throws -> String.SubSequence {
        return try self.get(index)
    }
}

extension Array where Element: Equatable {    
    func get(_ index: Int) throws -> Element {
        if self.indices.contains(index) {
            return self[index]
        } else {
            let error = NSError(domain:"array.get", code: 404, userInfo:["index": index])
            throw error
        }
    }
}

extension String {
    
    func replacingOccurrences(with variables: [String:String], prefix: String = "$") -> String {
        var s = self
        for t in variables {
            s = s
                .replacingOccurrences(of: "\(prefix){\(t.key)}", with: t.value)
                .replacingOccurrences(of: "\(prefix)\(t.key)", with: t.value)
        }
        return s
    }
    
}

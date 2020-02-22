//
//  Extensions.swift
//  
//
//  Created by Fatih Balsoy on 2/19/20.
//

import Foundation

extension Array where Element == StandardStream {
    mutating func appendOutput(_ exit: Int, _ output: [String], _ command: Command, _ error: Error? = nil) {
        print(exit, output)
        
        self.append(StandardStream(exitCode: exit, stream: output, error: error))
    }
    
    mutating func appendError(_ exit: Int, _ error: NSError, _ args: [String], _ command: Command) {
        let commandName = command.name
        let arguments = args.joined(separator: " ")
        self.appendOutput(exit, ["\(commandName): \(arguments): \(error.localizedFailureReason ?? error.localizedDescription)"], command)
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

//
//  Extensions.swift
//  
//
//  Created by Fatih Balsoy on 2/19/20.
//

import Foundation

extension Array where Element == StandardStream {
    public mutating func appendOutput(_ exit: Int, _ output: [String], _ command: Command, _ error: Error? = nil) {
        print(exit, output)
        
        self.append(StandardStream(exitCode: exit, stream: output, error: error))
    }
    
    public mutating func appendError(_ exit: Int, _ error: NSError, _ args: [String], _ command: Command) {
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
    
    func matches(_ regex: String) -> Bool {
        return self.range(of: regex, options: .regularExpression, range: nil, locale: nil) != nil
    }
    
    //
    //  MARK: - StringPadding.swift
    //
    //  Created by Zac Hallett on 12/8/14.
    //  Copyright (c) 2014 ID.me. All rights reserved.
    //
    func padding(fieldLength: Int) -> String {
        var formatedString: String = ""
        formatedString += self
        
        for _ in 1...(fieldLength - self.count) {
            formatedString += " "
        }
        
        return formatedString
    }
    
    //
    //  Created by Zac Hallett on 12/8/14.
    //  Copyright (c) 2014 ID.me. All rights reserved.
    //
    func padding(fieldLength: Int, paddingChar: String) -> String {
        var formatedString: String = ""
        formatedString += self
        
        for _ in 1...(fieldLength - self.count) {
            formatedString += paddingChar
        }
        
        return formatedString
    }
}

extension Date {
    func getFormattedDate(format: String? = "yyyy-MM-dd") -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let myString = formatter.string(from: self)
        let yourDate = formatter.date(from: myString)
        formatter.dateFormat = format
        let myStringafd = formatter.string(from: yourDate!)
        
        return myStringafd
    }
}

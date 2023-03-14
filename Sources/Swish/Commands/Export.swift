//
//  Export.swift
//  
//
//  Created by Fatih Balsoy on 2/22/20.
//

import Foundation

class _command_export: Command {
    
    required init(_ session: ShellSession) {
        super.init(session)
        name = "export"
        usage = "usage: export [-nf] [name[=value] ...] or export -p"
    }
    
    override func execute(_ args: [String]) -> Int {
        do {
            _ = try args.get(0)
            
            // Concept
            // $ a=b c=d
            // a=b
            // c=d
            // $ a=hello world
            // a=hello world
            
            // TODO:
            // $ a=b c d=e
            // c: command not found
            
            // MARK: - Multiple Exports
            var lastExport = ""
            for a in args {
                if a.contains("=") {
                    let split = a.split(maxSplits: 1, omittingEmptySubsequences: true) { (char) -> Bool in
                        return char == "="
                    }
                    if split.indices.contains(1) {
                        if split[1] != "" {
                            lastExport = String(split[0])
                            session.storage.set(String(split[1]), for: String(split[0]))
                        }
                    }
                } else {
                    if let lastVar = session.storage.get()[lastExport] {
                        session.storage.set(lastVar + " " + a, for: lastExport)
                    }
                }
            }
            return 0
        } catch let error as NSError {
            if !args.indices.contains(0) {
                session.stderr.appendOutput(1, [usage], self)
                return 1
            }
            session.stderr.appendError(1, error, args, self)
            return 1
        }
    }
}

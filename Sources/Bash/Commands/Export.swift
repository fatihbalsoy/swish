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
            
            for a in 0...args.count-1 {
                if args.indices.contains(a) && args[a].contains("=") {
                    let split = args[a].split(maxSplits: 1, omittingEmptySubsequences: true) { (char) -> Bool in
                        return char == "="
                    }
                    if split.indices.contains(1) {
                        if split[1] != "" {
                            session.storage.set(String(split[1]), for: String(split[0]))
                        }
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

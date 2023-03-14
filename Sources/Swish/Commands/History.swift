//
//  History.swift
//  
//
//  Created by Fatih Balsoy on 2/23/20.
//

import Foundation

class _command_history: Command {
    
    required init(_ session: ShellSession) {
        super.init(session)
        name = "history"
        usage = "usage: history [-c] [-d offset] [n] or history -awrn [filename] or history -ps arg [arg...]"
    }
    
    override func execute(_ args: [String]) -> Int {
        
        if args.contains("-c") {
            session.stdin.removeAll()
            return 0
        }
        let h = session.stdin
        var hFinal = [String]()
        var index = 0
        for c in h {
            let command = c.stream.joined(separator: " ")
            hFinal.append("\t\(index)\t\(command)")
            index += 1
        }
        session.stdout.appendOutput(0, hFinal, self)
        return 0
        
    }
    
}

//
//  Help.swift
//  
//
//  Created by Fatih Balsoy on 2/22/20.
//

import Foundation

class _command_help: Command {
    
    required init(_ session: ShellSession) {
        super.init(session)
        name = "help"
        usage = "usage: help [-s] [pattern ...]"
    }
    
    override func execute(_ args: [String]) -> Int {
        if args.indices.contains(0) {
            if let command = Bash(session: session).find(command: args[0]) {
                session.stdout.appendOutput(0, [command.usage], self)
                return 0
            }
        }
        
        var outputs = [String]()
        if let commands = Bash(session: session).findAllCommands() {
            for cmd in commands {
                if args.contains("-n") {
                    outputs.append(cmd.name)
                } else {
                    outputs.append(cmd.usage.replacingOccurrences(of: "usage: ", with: "\t"))
                }
            }
            session.stdout.appendOutput(0, outputs, self)
            return 0
        } else {
            session.stderr.appendOutput(1, ["No commands found"], self)
            return 1
        }
    }
}

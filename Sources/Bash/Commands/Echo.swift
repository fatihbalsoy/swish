//
//  Echo.swift
//  
//
//  Created by Fatih Balsoy on 2/19/20.
//

import Foundation

class _command_echo: Command {
    
    required init(_ session: ShellSession) {
        super.init(session)
        name = "echo"
        usage = "echo [-neE] [arg ...]"
    }
    
    override func execute(_ args: [String]) -> Int {
        let arg = args.joined(separator: " ")
        session.stdout.appendOutput(0, [arg], self)
        return 0
    }
}

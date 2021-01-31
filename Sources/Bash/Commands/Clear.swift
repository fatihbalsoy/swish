//
//  Clear.swift
//  
//
//  Created by Fatih Balsoy on 1/31/21.
//

import Foundation

class _command_clear: Command {
    
    required init(_ session: ShellSession) {
        super.init(session)
        name = "clear"
        usage = "usage: clear"
    }
    
    override func execute(_ args: [String]) -> Int {
        session.delegate?.terminal?(didClearOutput: session)
        return 0
    }
}

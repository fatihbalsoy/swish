//
//  File.swift
//  
//
//  Created by Fatih Balsoy on 1/31/21.
//

import Foundation

class _command_exit: Command {
    
    required init(_ session: ShellSession) {
        super.init(session)
        name = "exit"
        usage = "usage: exit"
    }
    
    override func execute(_ args: [String]) -> Int {
        // MARK: - Example output
//        Saving session...
//        ...copying shared history...
//        ...saving history...truncating history files...
//        ...completed.
//        Deleting expired sessions...      10 completed.
//
//        [Process completed]
        
        session.delegate?.terminal?(didExit: session)
        return 0
    }
}

//
//  Command.swift
//  
//
//  Created by Fatih Balsoy on 2/19/20.
//

import Foundation

open class Command {
    public var session: ShellSession!
    
    required public init(_ session: ShellSession) {
        self.session = session
    }
    
    /**
     The string that executes the command from bash
     
     Examples:
        - bash
        - touch
        - cd
        - echo
     */
    public var name: String = ""
    
    /**
     Usage of the command if the arguments do not match the requirements
     */
    public var usage: String = ""
    
    /**
        - Parameters:
            - args: The input given by the user
            - completion: Run code after bash command is complete
            - exit: Exit code returned when execution is complete
     
        - Returns:
            -  0 - The execution had no problems
            -  1 - Catchall for general errors
            -  2 - Misuse of shell builtins (according to Bash documentation)
            -  124 - Command timed out
            -  126 - Command invoked cannot execute
            -  127 - “command not found”
            -  128 - Invalid argument to exit
            -  128+n - Fatal error signal “n”
            -  130 - Script terminated by Control-C
            -  255\* - Exit status out of range
     */
    open func execute(_ args: [String]) -> Int { return 0 }
}

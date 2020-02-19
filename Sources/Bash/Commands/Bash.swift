//
//  Bash.swift
//  
//
//  Created by Fatih Balsoy on 2/18/20.
//

import Foundation

class Bash {
    var session: ShellSession!
    
    required init(session: ShellSession) {
        self.session = session
    }
    
    /**
        - Parameters:
            - args: The input given by the user
            - completion: Run code after bash command is complete
            - exit: Exit code returned when execution is complete
     
        - Returns:
            -  0 - The execution had no problems
            -  1 - Catchall for general errors
            -  2 - Misuse of shell builtins (according to Bash documentation)
            -  126 - Command invoked cannot execute
            -  127 - “command not found”
            -  128 - Invalid argument to exit
            -  128+n - Fatal error signal “n”
            -  130 - Script terminated by Control-C
            -  255\* - Exit status out of range
     */
    func execute(args: [String], completion: @escaping (_ exit: Int) -> Void) {
        do {
            let command = args.get(0)!
            if let command = find(command: command) {
                try session.writeTo(session.stdout, content: "Command found \(command)")
                completion(command.execute(args))
            } else {
                try session.writeTo(session.stderr, content: "Command not found \(command))")
                completion(127)
            }
        } catch {
            try! session.writeTo(session.stderr, content: "Unexpectedly crashed")
            completion(128)
        }
    }
    
    /**
     Finds and returns the bash command being executed
     
     - Parameters:
        - command: String that is used to find the class for the bash command
     
     - Returns
        Bash class deticated for the function
     */
    func find(command: String) -> Command? {
        guard let cls: AnyClass = NSClassFromString("Bash._command_\(command)") else { return nil }
        if let bashCommand = cls as? Command.Type {
            return bashCommand.init(session)
        }
        return nil
    }
}

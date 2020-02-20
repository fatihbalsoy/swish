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
        session.stdin.appendOutput(0, args.joined(separator: " "))
        
        do {
            let command = try args.get(0)
            if let command = find(command: command) {
                let output = command.execute(args)
                completion(output)
            } else {
                session.stderr.appendOutput(127, "-bash: \(command): command not found")
                completion(127)
            }
        } catch let error as NSError {
            if error.domain == "array.get" {
                if error.code == 404 {
                    if error.userInfo["index"] as? Int == 0 {
                        session.stderr.appendOutput(0, "-bash: 0: command not found")
                        completion(0)
                    }
                }
            } else {
                session.stderr.appendOutput(128, "Fatal error")
                completion(128)
            }
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
    
    /**
     Finds and returns a list of all bash commands available
     
     - Returns
        List of classes available to use with bash in the project
     */
    func findAllCommands() -> [Command]? {
        let commandClassInfo = ClassInfo(Command.self)!
        var subclassList = [ClassInfo]()
        var commandsList = [Command]()

        var count = UInt32(0)
        let classList = objc_copyClassList(&count)!

        for i in 0..<Int(count) {
            if let classInfo = ClassInfo(classList[i]),
                let superclassInfo = classInfo.superclassInfo,
                superclassInfo == commandClassInfo
            {
                subclassList.append(classInfo)
            
                if let bashCommand = classInfo.classObject as? Command.Type {
                    commandsList.append(bashCommand.init(session))
                }
            }
        }
        
        return commandsList
    }
}

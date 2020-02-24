//
//  Bash.swift
//  
//
//  Created by Fatih Balsoy on 2/18/20.
//

import Foundation

public class Bash {
    public var session: ShellSession!
    public var commands = [Command]()
    var tabCounts = [String : Int]()
    
    public required init(session: ShellSession) {
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
    open func execute(_ input: String, hidden: Bool = false, completion: @escaping (_ exit: Int) -> Void) {
        let args = session.convertToArguments(input: input)
        if !hidden {
            _ = session.stdin.appendOutput(0, [args.joined(separator: " ")], Command(session))
        }
        
        do {
            let commandName = try args.get(0)
            tabCounts.removeValue(forKey: commandName)
            if let command = self.find(command: commandName) {
                let arguments = Array(args[1..<args.endIndex])
                let output = command.execute(arguments)
                completion(output)
            } else if args[0] == "" {
                completion(0)
            } else if args[0].contains("=") {
                completion(_command_export(session).execute(args))
            } else {
                self.session.stderr.appendOutput(127, ["-bash: \(commandName): command not found"], Command(session))
                completion(127)
            }
        } catch let error as NSError {
            if error.domain == "array.get" {
                if error.code == 404 {
                    if error.userInfo["index"] as? Int == 0 {
                        session.stderr.appendOutput(0, ["-bash: 0: command not found"], Command(session), error)
                        completion(0)
                    }
                }
            } else {
                session.stderr.appendOutput(128, ["Fatal error"], Command(session), error)
                completion(128)
            }
        }
    }
    
    /**
     Auto-completes the last argument, usually done by the tab key.
     
     - Parameters:
        - input: The input given by the user when clicked on tab
        - count: The amount of times tab was clicked. This is automatic, but can be used if you're not executing commands.
     
     - Returns:
        - String that includes the hint at the end of the input
     */
    open func tab(_ input: String, count: Int? = nil) -> String {
        let args = session.convertToArguments(input: input)
        
        do {
            let command = try args.get(0)
            if tabCounts[command] != nil {
                if let count = count {
                    tabCounts[command]? = count
                } else {
                    tabCounts[command]? += 1
                }
            } else {
                tabCounts[command] = 1
            }
            print(tabCounts)
            
            if let commandClass = self.find(command: command) {
                let arguments = Array(args[1..<args.endIndex])
                let output = commandClass.tab(arguments, count: tabCounts[command] ?? 0)
                return output
            } else {
                if args.indices.contains(1) {
                    let custom = Command(session)
                    let tab = custom.defaultTab(args, count: tabCounts[command] ?? 0)
                    return String(tab.dropFirst())
                } else {
                    let custom = Command(session)
                    let tab = custom.defaultTab(args, count: tabCounts[command] ?? 0, pipe: "help -n")
                    return String(tab.dropFirst())
                }
            }
        } catch {
            print("TAB: could not auto-complete")
        }
        return input
    }
    
    
    /**
     Finds and returns the bash command being executed
     
     - Parameters:
        - command: String that is used to find the class for the bash command
     
     - Returns
        Bash class deticated for the function
     */
    func find(command: String) -> Command? {
        guard let cls: AnyClass = NSClassFromString("Bash._command_\(command)") else {
            if let custom = commands.first(where: { (cmd) -> Bool in
                return cmd.name == command
            }) {
                return type(of: custom).init(session)
            } else {
                return nil
            }
        }
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
        commandsList.append(contentsOf: commands)
        
        return commandsList
    }
}

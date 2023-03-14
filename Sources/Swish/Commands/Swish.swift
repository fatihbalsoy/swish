//
//  Swish.swift
//  
//
//  Created by Fatih Balsoy on 2/18/20.
//

import Foundation

public class Swish {
    public var session: ShellSession!
    public var commands = [Command]()
    var tabCounts = [String : Int]()
    
    public required init(session: ShellSession) {
        self.session = session
        execute("mkdir /home/user", hidden: true) { (exit) in }
    }
    
    /**
        - Parameters:
            - input: The input given by the user
            - hidden: Hide output from history
            - completion: Run code after swish command is complete
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
            session.stdin.appendOutput(0, [args.joined(separator: " ")], Command(session))
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
                self.session.stderr.appendOutput(127, ["-swish: \(commandName): command not found"], Command(session))
                completion(127)
            }
        } catch let error as NSError {
            if error.domain == "array.get" {
                if error.code == 404 {
                    if error.userInfo["index"] as? Int == 0 {
                        session.stderr.appendOutput(0, ["-swish: 0: command not found"], Command(session), error)
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
        - Parameters:
            - input: The input given by the user
            - hidden: Hide output from history
     
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
    open func execute(_ input: String, hidden: Bool = false) -> Int {
        var result = 0
        execute(input, hidden: hidden) { (exit) in
            result = exit
        }
        return result
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
     Finds and returns the swish command being executed
     
     - Parameters:
        - command: String that is used to find the class for the swish command
     
     - Returns
        Swish class deticated for the function
     */
    func find(command: String) -> Command? {
        guard let cls: AnyClass = NSClassFromString("Swish._command_\(command)") else {
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
     Finds and returns an alphabetically sorted list of all swish commands available
     
     April 14, 2020: Updated for Xcode 11.4, iOS 13.4, and macOS 10.15.4
     
     `https://stackoverflow.com/questions/60853427/objc-copyclasslist-crash-exc-bad-instruction-after-update-to-ios-13-4-xcode-1`
     
     - Returns
        List of classes available to use with swish in the project
     */
    func findAllCommands() -> [Command]? {
        let commandClassInfo = ClassInfo(Command.self)
        var commandsList = [Command]()

        var count = UInt32(0)
        guard let classListPointer = objc_copyClassList(&count) else { return [] }
        let classList = UnsafeBufferPointer(start: classListPointer, count: Int(count))
            .map(ClassInfo.init)
            .filter { $0?.superclassInfo == commandClassInfo }
        
        let sortedClassList = classList.sorted { (aX, bX) -> Bool in
            guard let a = aX?.classObject as? Command.Type else { return false }
            guard let b = bX?.classObject as? Command.Type else { return false }
            
            let aCMD = a.init(self.session)
            let bCMD = b.init(self.session)
            return aCMD.name < bCMD.name
        }

        for i in 0..<Int(sortedClassList.count) {
            if let classInfo = sortedClassList[i] {
                if let bashCommand = classInfo.classObject as? Command.Type {
                    commandsList.append(bashCommand.init(self.session))
                }
            }
        }
        
        commandsList.append(contentsOf: commands)
        
        return commandsList
    }
}

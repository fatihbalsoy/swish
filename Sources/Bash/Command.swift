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
    
     /**
      Auto-completes the last argument, usually done by the tab key.
      
      - Parameters:
         - args: The input given by the user when clicked on tab
         - count: The amount of times the tab key was clicked
      
      - Returns:
         - String that includes the hint at the end of the input
      */
    open func tab(_ args: [String], count: Int) -> String { return defaultTab(args, count: count) }
    
    // FIXME: Doesn't work with files out of scope, ex: cd /home/compl *tab*
    open func defaultTab(_ args: [String], count: Int, pipe: String = "ls -a") -> String {
        var toReturn = args.last ?? ""
        var parent = ""
        
        if let l = args.last {
            var defaultPipe = pipe
            var last = l
            
            if pipe == "ls -a" && last.last != "/" {
                var split = last.components(separatedBy: "/")
                last = split.removeLast()
                if split.joined() != "" {
                    parent = split.joined(separator: "/") + "/"
                    defaultPipe = pipe + " " + parent
                    print(split, "->",defaultPipe)
                }
            }
            
            /// Add grep and pipes to simplify this to:
            /// ls | grep "^`last`"
            Bash(session: session).execute(defaultPipe, hidden: true) { (exit) in
                if let files = self.session.stdout.last {

                    var found = [String]()
                    
                    for file in files.stream {
                        if file.starts(with: last) {
                            found.append(file)
                        }
                    }
                    if count > 1 && found.count > 1 {
                        self.session.stdout.removeLast()
                        self.session.stdout.appendOutput(0, found, self)
                        Bash(session: self.session).tabCounts.removeValue(forKey: self.name)
                    } else if found.count == 1 {
                        let index = files.stream.first { (s) -> Bool in
                            return s.starts(with: last)
                        }
                        toReturn = index ?? last
                        
                        var isDir: ObjCBool = false
                        if let path = self.session.getFilePathURL(withFile: parent + toReturn).absoluteURL?.path {
                            let d = FileManager.default.fileExists(atPath: path, isDirectory: &isDir)
                            if isDir.boolValue {
                                toReturn += "/"
                            }
                        }
                        
                        self.session.stdout.removeLast()
                    } else {
                        self.session.stdout.removeLast()
                    }
                }
            }
        }
        
        var drop = args.dropLast()
        drop.append(toReturn)
        return name + " " + parent + drop.joined(separator: " ")
    }
}

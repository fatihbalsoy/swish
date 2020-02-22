//
//  Session.swift
//  
//
//  Created by Fatih Balsoy on 2/19/20.
//

import Foundation

public struct StandardStream {
    public var exitCode: Int
    public var stream: [String]
    public var error: Error?
    
    public init(exitCode: Int, stream: [String], error: Error? = nil) {
        self.exitCode = exitCode
        self.stream = stream
        self.error = error
    }
}

public class ShellSession {
    
    /// Standard input is a stream from which a program reads its input data.
    public var stdin = [StandardStream]()
    
    /// Standard output is a stream to which a program writes its output data.
    public var stdout = [StandardStream]()
    
    /// Standard error is another output stream typically used by programs to output error messages or diagnostics.
    public var stderr = [StandardStream]()
    
    /// The unique identifier is used to identify the shell session between a list of other sessions.
    let uuid: String
    
    /// Stores variables created during the session
    public var storage = BashStorage()
    
    /// Root path of the current shell environment is set to a sandboxed documents folder
    let rootPath: NSURL
    /// Home path of the current user that created the shell session
    var homePath: NSURL
    /// The current path the session is operating in
    var currentPath: NSURL
    
    /**
     Prompt displayed before the user input field
     
     https://www.cyberciti.biz/tips/howto-linux-unix-bash-shell-setup-prompt.html
     https://linuxconfig.org/bash-prompt-basics#h3-bash-ps1-prompt-variable
     
     - \\a : an ASCII bell character (07)
     - \\d : the date in “Weekday Month Date” format (e.g., “Tue May 26”)
     - \\D{format} : the format is passed to strftime(3) and the result is inserted into the prompt string; an empty format - results in a locale-specific time representation. The braces are required
     - \\e : an ASCII escape character (033)
     - \\h : the hostname up to the first ‘.’
     - \\H : the hostname
     - \\j : the number of jobs currently managed by the shell
     - \\l : the basename of the shellâ€™s terminal device name
     - \\n : newline
     - \\r : carriage return
     - \\s : the name of the shell, the basename of $0 (the portion following the final slash)
     - \\t : the current time in 24-hour HH:MM:SS format
     - \\T : the current time in 12-hour HH:MM:SS format
     - \\@ : the current time in 12-hour am/pm format
     - \\A : the current time in 24-hour HH:MM format
     - \\u : the username of the current user
     - \\v : the version of bash (e.g., 2.00)
     - \\V : the release of bash, version + patch level (e.g., 2.00.0)
     - \\w : the current working directory, with $HOME abbreviated with a tilde
     - \\W : the basename of the current working directory, with $HOME abbreviated with a tilde
     - \\! : the history number of this command
     - \\# : the command number of this command
     - \\$ : if the effective UID is 0, a #, otherwise a $
     - \\nnn : the character corresponding to the octal number nnn
     - \\\ : a backslash
     - \\[ : begin a sequence of non-printing characters, which could be used to embed a terminal control sequence into the prompt
     - \\] : end a sequence of non-printing characters
     */
    public var prompt: String {
        get {
            let lineStorage = [
                "\\h": storage.get()["HOSTNAME"] ?? "bash",
                "\\W": currentPath == homePath ? "~" : currentPath.pathComponents?.last ?? "~",
                "\\u": storage.get()["USER"] ?? "user",
                "\\$": "$"
            ]
            return (storage.get()["PS1"]?.replacingOccurrences(with: lineStorage, prefix: "").replacingOccurrences(of: ".local", with: "") ?? "") + " "
        }
    }
    
    public init(user: String, hostname: String, root: NSURL, uuid: String = UUID().uuidString) {
        self.uuid = uuid
        self.rootPath = root
        
        let home = "/home/\(user)"
        storage.set(from: [
            "0": "-bash",
            "PS1": "\\h:\\W \\u\\$",
            "PS2": ">",
            "PS4": "+",
            "RANDOM": "",
            "UUID": uuid,
            "USER": user,
            "HOME": home,
            "HOSTNAME": hostname
        ])
        
        homePath = rootPath.appendingPathComponent(home)! as NSURL
        currentPath = homePath
    }
    
    /**
     Converts string to array of arguments, and replaces variables.
     
         let args = convertToArguments(input: 'echo "hi" "hello $w"')
         print(args)
         // [echo, hi, hello world]
     */
    func convertToArguments(input: String) -> [String] {
//        let separator = UUID().uuidString
//        let dollar = UUID().uuidString
        
//        let split = input.split(separator: "\"")
//        var array = [String]()
//        for s in split {
//            array.append(s.trimmingCharacters(in: .whitespaces).replacingOccurrences(with: storage.get()))
//        }
        
        return input.components(separatedBy: " ")
    }
    
    /// Root, home, and current
    enum PathIndex { case root, home, current }
    /**
     Solves the parent path of the referenced directory
     
     - Parameters:
        - path: Path that either starts with `/`, `~`, or nothing.
     
     - Returns:
        - /example → PathIndex.root
        - ~/example → PathIndex.home
        - example → PathIndex.current
     */
    func solveDirectoryRoot(path: String) -> PathIndex {
        switch path.first {
        case "/": return .root
        case "~": return .home
        default: return .current
        }
    }
    /**
     Path of the input's parent.
     
     - Parameters:
        - path: The path of the file prefixed by a reference to another directory or neither.
     
     - Returns:
         - /example → /
         - ~/example → /home/user/
         - example → /home/user/Documents/
     */
    func getPathURL(withPath path: String) -> NSURL {
        let dirRoot = solveDirectoryRoot(path: path)
        print("DIRROOT:",dirRoot)
        let pathDir = dirRoot == .home ? homePath : dirRoot == .root ? rootPath : currentPath
        return pathDir
    }
    
    /**
     Path of the file, prefixed with the parent directory
     
     - Parameters:
        - path: The path of the file prefixed by a reference to another directory or neither.
     
     - Returns:
         - /example → /example
         - ~/example → /home/user/example
         - example → /home/user/Documents/example
     */
    func getFilePathURL(withFile path: String) -> NSURL {
        let dirRoot = getPathURL(withPath: path)
        let newFilePath = trimPath(dir: path)
        let pathDir = dirRoot.appendingPathComponent(newFilePath)
        print("GETFILE:",path,dirRoot, newFilePath, pathDir)
        return pathDir! as NSURL
    }
    
    /**
     Removes the `~` character from the directory parameter if it exists
     
     - Parameters:
        - dir: Directory that might be prefixed by the `~` character
     */
    func trimPath(dir: String) -> String {
        let trimFile = dir.starts(with: "~/")
            ? String(dir.dropFirst().dropFirst())
            : dir
        return trimFile
    }
}

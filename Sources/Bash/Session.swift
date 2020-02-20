//
//  Session.swift
//  
//
//  Created by Fatih Balsoy on 2/19/20.
//

import Foundation

class Shell {
    /**
     Stores every shell session created using the `createSession()` function to easily switch between environments.
     */
    static var sessions = [String : ShellSession]()
    /// The UUID of the current shell session
    static var mainSession: String?
    
    /// Root path of the current shell environment
    let root: NSURL
    
    init(root: NSURL? = nil) {
        let url = NSURL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])
        let safeguard = url.appendingPathComponent("BashSwift/root")
        self.root = root ?? safeguard! as NSURL
    }
    
    /**
     Creates a new shell session and returns it when complete.
     If it already exists, the function just returns the session and skips creating it.
     */
    func session (user: String = "user", hostname: String = "hostname", uuid: String = UUID().uuidString, completion: @escaping (_ exists: Bool, _ session: ShellSession) -> Void) {
        
        if Shell.mainSession == nil { Shell.mainSession = uuid }
        
        if let session = Shell.sessions[uuid] {
            completion(true, session)
        } else {
            let session = ShellSession(user: user, hostname: hostname, root: root, uuid: uuid)
            Shell.sessions[uuid] = session
            completion(false, session)
        }
    }
}

struct StandardStream {
    var exitCode: Int
    var stream: String
}

class ShellSession {
    
    /// Standard input is a stream from which a program reads its input data.
    var stdin = [StandardStream]()
    
    /// Standard output is a stream to which a program writes its output data.
    var stdout = [StandardStream]()
    
    /// Standard error is another output stream typically used by programs to output error messages or diagnostics.
    var stderr = [StandardStream]()
    
    /// The unique identifier is used to identify the shell session between a list of other sessions.
    let uuid: String
    
    /// Stores variables created during the session
    var storage = BashStorage()
    
    /// Root path of the current shell environment is set to a sandboxed documents folder
    let rootPath: NSURL
    /// Home path of the current user that created the shell session
    var homePath: NSURL
    /// The current path the session is operating in
    var path: NSURL
    
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
    var prompt: String {
        get {
            let lineStorage = [
                "\\h": storage.get()["HOSTNAME"] ?? "bash",
                "\\W": path == homePath ? "~" : path.pathComponents?.last ?? "~",
                "\\u": storage.get()["USER"] ?? "user",
                "\\$": "$"
            ]
            return storage.get()["PS1"]?.replacingOccurrences(with: lineStorage, prefix: "") ?? ""
        }
    }
    
    init(user: String, hostname: String, root: NSURL, uuid: String = UUID().uuidString) {
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
        path = homePath
    }
}

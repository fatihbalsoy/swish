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
    static var mainSession: String?
    
    func createSession
        (uuid: String = UUID().uuidString, completion: @escaping (_ exists: Bool, _ session: ShellSession) -> Void) {
        
        if Shell.mainSession == nil { Shell.mainSession = uuid }
        
        if let session = Shell.sessions[uuid] {
            completion(true, session)
        } else {
            let session = ShellSession(uuid: uuid)
            Shell.sessions[uuid] = session
            completion(false, session)
        }
    }
}

class ShellSession {
    
    let proc = Process()
    
    /// Standard input is a stream from which a program reads its input data.
    var stdin = Pipe()
    
    /// Standard output is a stream to which a program writes its output data.
    var stdout = Pipe()
    
    /// Standard error is another output stream typically used by programs to output error messages or diagnostics.
    var stderr = Pipe()
    
    private var _uuid: String!
    /// The unique identifier is used to identify the shell session between a list of other sessions.
    var uuid: String {
        set {
            if _uuid == nil {
                _uuid = newValue
            }
        }
        get {
            return _uuid
        }
    }
    
    init(uuid: String = UUID().uuidString) {
        self.uuid = uuid
    }
    
    /**
     Writes text to a given pipe
     
     - Parameters:
         - pipe: The output stream that will be modified
         - content: The content that will be written into the given pipe
     
     */
    func writeTo(_ pipe: Pipe, content: String) throws {
        pipe.fileHandleForWriting.write(content.data(using: .utf8)!)
    }
}

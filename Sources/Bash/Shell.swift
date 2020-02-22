//
//  Shell.swift
//  
//
//  Created by Fatih Balsoy on 2/21/20.
//

import Foundation

public class Shell {
    /**
     Stores every shell session created using the `createSession()` function to easily switch between environments.
     */
    static var sessions = [String : ShellSession]()
    /// The UUID of the current shell session
    static var mainSession: String?
    
    /// Root path of the current shell environment
    let root: NSURL
    
    /// Default documents folder where the simulated shell is based on
    public static let documentsURL = NSURL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])
    
    public init(root: NSURL? = nil) {
        let safeguard = Shell.documentsURL.appendingPathComponent("BashSwift/root")
        self.root = root ?? safeguard! as NSURL
    }
    
    /**
     Creates a new shell session and returns it when complete.
     If it already exists, the function just returns the session and skips creating it.
     */
    public func session (user: String = "user", hostname: String = "hostname", uuid: String = UUID().uuidString, completion: @escaping (_ exists: Bool, _ session: ShellSession) -> Void) {
        
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

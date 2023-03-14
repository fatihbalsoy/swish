//
//  File.swift
//  
//
//  Created by Fatih Balsoy on 2/24/20.
//

import Foundation

class _command_pwd: Command {

    required init(_ session: ShellSession) {
        super.init(session)
        name = "pwd"
        usage = "usage: pwd [-LP]"
    }
    
    override func execute(_ args: [String]) -> Int {
        let replace: String! = args.contains("-P") ? "file://" : session.rootPath.absoluteString
        guard let current = session.currentPath.absoluteString?.replacingOccurrences(of: replace, with: "") else { return 0 }
        session.stdout.appendOutput(0, [current], self)
        return 0
    }
    
}

//
//  Date.swift
//  
//
//  Created by Fatih Balsoy on 2/22/20.
//

import Foundation

class _command_date: Command {
    
    required init(_ session: ShellSession) {
        super.init(session)
        name = "date"
        usage = "usage: date [-jnRu] [-d dst] [-r seconds] [-t west] [-v[+|-]val[ymwdHMS]] or date [-f fmt date | [[[mm]dd]HH]MM[[cc]yy][.ss]] [+format]"
    }
    
    override func execute(_ args: [String]) -> Int {
        let date = Date().getFormattedDate(format: "E MMM d HH:mm:ss z yyyy")
        session.stdout.appendOutput(0, [date], self)
        return 0
    }
    
}

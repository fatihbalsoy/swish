//
//  Expr.swift
//  
//
//  Created by Fatih Balsoy on 1/13/21.
//

import Foundation
import MathParser

class _command_expr: Command {
    
    required init(_ session: ShellSession) {
        super.init(session)
        name = "expr"
        usage = "usage: expr [math expression]"
    }
    
    override func execute(_ args: [String]) -> Int {
        do {
            let expression = args.joined()
            let result = try expression.evaluate()
            
            let format = result.truncatingRemainder(dividingBy: 1) == 0 ? "\(Int(result))" : "\(result)"
            
            // FIXME: * should give 'syntax error' and \* should be multiplication
            session.stdout.appendOutput(0, [format], self)
            return 0
        } catch let error as NSError {
            if !args.indices.contains(0) {
                session.stderr.appendOutput(1, [usage], self)
                return 1
            }
            session.stderr.appendError(1, error, args, self)
            return 1
        }
    }
}

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
        usage = "usage: expr [-h|math expression]"
    }
    
    override func execute(_ args: [String]) -> Int {
        if args.contains("-h") || args.contains("--help") {
            return help()
        }
        do {
            let expression = args.joined()
            let result = try expression.evaluate()
            
            let format = result.truncatingRemainder(dividingBy: 1) == 0 ? "\(Int(result))" : "\(result)"
            
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
    
    private func help() -> Int {
        let help = [
            "Standard Operators",
            "\t add: +",
            "\t subtract: - or −",
            "\t multiply: * or ×",
            "\t divide: / or ÷",
            "\t mod or percent: %",
            "\t factorial: !",
            "\t factorial2: !!",
            "\t power: **",
            "\t convert to radians: º or ° or ∘",
            "\t square root: √",
            "\t cubic root: ∛",
            "",
            "Bitwise Operators",
            "\t and: &",
            "\t or: |",
            "\t xor: ^r",
            "\t not: ~",
            "\t left shift: <<",
            "\t right shift: >>",
            "",
            "Comparison Operators",
            "\t equal: == or =l",
            "\t not equal: != or ≠",
            "\t less than: <",
            "\t greater than: >",
            "\t less than or equal: <= or =< or ≤ or ≯",
            "\t greater than or equal: >= or => or ≥ or ≮",
            "",
            "Logical Operators",
            "\t and: && or ∧",
            "\t or: || or ∨",
            "\t not: ! or ¬",
        ]
        session.stdout.appendOutput(0, help, self)
        return 0
    }
}

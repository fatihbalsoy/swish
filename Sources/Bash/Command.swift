//
//  Command.swift
//  
//
//  Created by Fatih Balsoy on 2/19/20.
//

import Foundation

protocol _CommandProtocol {
    var session: ShellSession! { get set }
    init(_ session: ShellSession)
    func execute(_ args: [String]) -> Int
}

typealias Command = _CommandProtocol

//
//  ViewController.swift
//  SwishTerminal
//
//  Created by Fatih Balsoy on 1/24/21.
//

import UIKit
import SnapKit
import Swish

class ViewController: UIViewController, UITextViewDelegate, ShellSessionDelegate {
    
    var textView: UITextView = {
        let view = UITextView()
        if #available(iOS 13.0, *) {
            view.font = UIFont.monospacedSystemFont(ofSize: 11, weight: .regular)
        } else {
            view.font = UIFont(name: "Menlo-Regular", size: 11)
        }
        
        // Turn off auto-correction
        view.autocorrectionType = .no
        view.autocapitalizationType = .none
        view.spellCheckingType = .no
        if #available(iOS 11.0, *) {
            view.smartQuotesType = .no
            view.smartDashesType = .no
        } else {
            // Fallback on earlier versions
        }
        return view
    }()
    
    var prefixUntouched = ""
    var prefix: String { get { return "[" + prefixUntouched } set { prefixUntouched = newValue } }
    var tabCount = 0
    var content = ["Swish 1.0"]
    var currentInput = ""
    var contentByteSize: Int {
        return content.joined(separator: "\n").count
    }
    
    var swish: Swish?
    // TODO: Change to StandardOutput
    var stdin = [StandardStream]()
    var stdout = [String]()
    var stderr = [String]()
    
    override var keyCommands: [UIKeyCommand]? {
        func keyPress(input: String, modifierFlags: UIKeyModifierFlags, action: Selector, title: String) -> UIKeyCommand {
            #if targetEnvironment(macCatalyst)
            return UIKeyCommand(input: input, modifierFlags: modifierFlags, action: action)
            #else
            return UIKeyCommand(input: input, modifierFlags: modifierFlags, action: action, discoverabilityTitle: title)
            #endif
        }
        return [
            keyPress(input: "\t", modifierFlags: [], action: #selector(tabKey), title: "Autocomplete"),
            keyPress(input: UIKeyCommand.inputUpArrow, modifierFlags: [], action: #selector(upKey), title: "Previous Input"),
            keyPress(input: UIKeyCommand.inputDownArrow, modifierFlags: [], action: #selector(downKey), title: "Previous Input")
        ]
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        textView.delegate = self
        
        Shell(root: Shell.documentsURL).session(user: "user", hostname: "swish", uuid: UUID().uuidString) { (exists, session) in
            self.swish = Swish(session: session)
            self.prefix = session.prompt
        }
        swish?.session.delegate = self
        
        layout()
        refreshTerminal(append: true)
    }
    
    func refreshTerminal(append: Bool = false) {
        if append {
            content.append(prefix)
        }
        textView.text = content.joined(separator: "\n") + currentInput
    }
    
    func appendToCurrentLine(_ string: String) {
        currentInput = currentInput + string
        refreshTerminal()
    }
    
    // MARK: - Autocomplete
    @objc func tabKey() {
        tabCount += 1
        let input = getCurrentInput()
        let tab = swish?.tab(input, count: tabCount)
        if let output = self.swish?.session.stdout.last {
            content[content.count - 1].append(input)
            pullOutput(output.exitCode)
            refreshTerminal(append: true)
            // print("a")
        } else if let t = tab {
            currentInput = t
            pullOutput(0)
            refreshTerminal()
            // print("b")
        }
    }
    
    // MARK: - History Navigation
    private var hIndex = 0
    private var currentInputBackup = ""
    var historyIndex: Int {
        get {
            return hIndex
        }
        set {
            hIndex = newValue > stdin.count ? stdin.count : newValue < 0 ? 0 : newValue
        }
    }
    @objc func upKey() { arrowKey(up: true) }
    @objc func downKey() { arrowKey(up: false) }
    func arrowKey(up: Bool) {
        if historyIndex == 0 {
            currentInputBackup = currentInput
        }
        if up {
            historyIndex += 1
        } else {
            historyIndex -= 1
        }
        
        let index = stdin.count - historyIndex
        if stdin.indices.contains(index) {
            currentInput = stdin[index].stream.joined()
        } else {
            currentInput = currentInputBackup
        }
        refreshTerminal()
    }
    
    // MARK: - Execution
    func execute(_ args: String) {
        swish?.execute(args, completion: { (exit) in
            self.pullOutput(exit)
            self.prefix = self.swish?.session.prompt ?? ""
            self.tabCount = 0
            self.historyIndex = 0
            self.currentInput = ""
            self.refreshTerminal(append: true)
        })
    }
    
    func pullOutput(_ exit: Int) {
        if let input = self.swish?.session.stdin {
            stdin = input
        }
        
        let output = (exit == 0 ? self.swish?.session.stdout.last?.stream : self.swish?.session.stderr.last?.stream) ?? []
        if exit == 0 {
            self.stdout.append(contentsOf: output)
            self.swish?.session.stdout.removeAll()
        } else {
            self.stderr.append(contentsOf: output)
            self.swish?.session.stderr.removeAll()
        }
        self.content.append(contentsOf: output)
    }

    // MARK: - Interface
    func layout() {
        // let window = UIApplication.shared.keyWindow
        let window = UIApplication.shared.windows[0]
        var topPadding: CGFloat = 0
        var bottomPadding: CGFloat = 0
        if #available(iOS 11.0, *) {
            topPadding = window.safeAreaInsets.top
            bottomPadding = window.safeAreaInsets.bottom
        }
        #if targetEnvironment(macCatalyst)
        topPadding = 25
        #endif
        
        view.addSubview(textView)
        textView.snp.makeConstraints { (make) in
            make.left.right.equalTo(view)
            make.top.equalTo(view).offset(topPadding)
            make.bottom.equalTo(view).offset(-bottomPadding)
        }
    }
    
    func terminal(didClearOutput session: ShellSession) {
        content = []
        refreshTerminal()
    }
    
    func terminal(didExit session: ShellSession) {
        UIControl().sendAction(#selector(URLSessionTask.suspend), to: UIApplication.shared, for: nil)
        exit(0)
    }
    
    // MARK: - TextView
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if range.location >= contentByteSize {
            return true
        }
        return false
    }
    
    func getCurrentInput() -> String {
        let current = textView.text ?? ""
        let split = current.substring(from: contentByteSize)
        return split
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let split = getCurrentInput()
        currentInput = split
        
        if split.contains("\n") {
            let stripped = split.replacingOccurrences(of: "\n", with: "")
            content[content.count - 1].append(stripped)
            execute(stripped)
        }
    }
}

// MARK: - Extensions
extension String {
    func substring(from: Int?, to: Int?) -> String {
        if let start = from {
            guard start < self.count else {
                return ""
            }
        }

        if let end = to {
            guard end >= 0 else {
                return ""
            }
        }

        if let start = from, let end = to {
            guard end - start >= 0 else {
                return ""
            }
        }

        let startIndex: String.Index
        if let start = from, start >= 0 {
            startIndex = self.index(self.startIndex, offsetBy: start)
        } else {
            startIndex = self.startIndex
        }

        let endIndex: String.Index
        if let end = to, end >= 0, end < self.count {
            endIndex = self.index(self.startIndex, offsetBy: end + 1)
        } else {
            endIndex = self.endIndex
        }

        return String(self[startIndex ..< endIndex])
    }

    func substring(from: Int) -> String {
        return self.substring(from: from, to: nil)
    }

    func substring(to: Int) -> String {
        return self.substring(from: nil, to: to)
    }

    func substring(from: Int?, length: Int) -> String {
        guard length > 0 else {
            return ""
        }

        let end: Int
        if let start = from, start > 0 {
            end = start + length - 1
        } else {
            end = length - 1
        }

        return self.substring(from: from, to: end)
    }

    func substring(length: Int, to: Int?) -> String {
        guard let end = to, end > 0, length > 0 else {
            return ""
        }

        let start: Int
        if let end = to, end - length > 0 {
            start = end - length + 1
        } else {
            start = 0
        }

        return self.substring(from: start, to: to)
    }
}

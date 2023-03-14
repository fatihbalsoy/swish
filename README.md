![Alt text](.readme/banner.png?raw=true  "SwiftyRuler")

[![Swift](https://img.shields.io/badge/swift-5.1-orange)](https://github.com/apple/swift/tree/swift-5.1-branch)
[![build](https://img.shields.io/github/actions/workflow/status/fatihbalsoy/swish/.github/workflows/swift.yml)](https://github.com/fatihbalsoy/swish/actions)
[![License](https://img.shields.io/github/license/fatihbalsoy/swish?color=blue)](https://github.com/fatihbalsoy/swish/blob/master/LICENSE)
![iOS](https://img.shields.io/badge/iOS-8.0%2B-blue)
![macOS](https://img.shields.io/badge/macOS-10.10%2B-orange)
![tvOS](https://img.shields.io/badge/tvOS-9.0%2B-white)

Swish is a Swift-based project that recreates a shell environment similar to Bash without relying on virtualization. It has a variety of potential uses in Swift applications, including emulating a terminal within a game or app, testing new features without a UI, and etc. With Swish, developers can enjoy the flexibility and functionality of a shell environment without needing to virtualize Bash/Zsh.

Developers can expand the capabilities of Swish by creating their own commands. Instructions can be found [here](https://github.com/fatihbalsoy/swish#custom-commands).

The nature of this Swift Package should be compliant with Apple's App Store policies. Although this has not been tested.

## Example

To run the example project, clone the repo, open `SwishTerminal.xcodeproj` within the `Terminal-Example` folder, and run the project.

![Alt text](.readme/screenshot.png?raw=true  "Example")

## Installation

### Swift Package Manager

To integrate using Apple's [Swift Package Manager](https://swift.org/package-manager/), add the following as a dependency to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/fatihbalsoy/swish.git", from: "0.1.0")
]
```

Alternatively, navigate to your Xcode project, go to `File > Add Packages...` and search for `https://github.com/fatihbalsoy/swish`.

### Manually

If you prefer not to use a dependency manager, you can integrate Swish into your project manually. Simply drag the files in the `Sources` folder into your Xcode project.

## Usage

``` swift
import Swish

class Example: ShellSessionDelegate {
    
    var swish: Swish?
    var prefix: String?

    init() {
        // Initialize Shell environment in Documents folder
        Shell(root: Shell.documentsURL)
            // Session for user
            .session(user: "user", hostname: "swish", uuid: UUID().uuidString) { (exists, session) in
            self.swish = Swish(session: session)
            self.prefix = session.prompt
        }
        swish?.session.delegate = self

        // Execute `echo` command
        execute("echo hello there!")

        // Execute `touch` command
        execute("touch kenobi.txt")
    }

    // Command execution
    func execute(_ args: String) {
        swish?.execute(args, completion: { 
            (exit) in
            
            // Use `self.swish?.session.stdout`
            // to pull output from shell session.
            // - stdin for input
            // - stderr for errors

            // You can refresh your 
            // terminal UI here
        })
    }

}
```

### ShellSessionDelegate functions

```swift
func terminal(didUpdateOutput session: ShellSession)
```
Triggered when an output was added to stdout or stderr. Can be used to update the terminal interface.

<br>

```swift
func terminal(didClearOutput session: ShellSession)
```
Triggered when the `clear` command is executed. Can be used to clear a custom terminal interface.

<br>

```swift
func terminal(didExit session: ShellSession)
```
Triggered when the `exit` command is executed. Can be used to close a view controller or the entire app by calling `exit(0)` in Swift.

## Commands

- [x] `cat` - display file contents
- [x] `cd` - change directory
- [x] `clear` - clear terminal
- [x] `cp` - copy files
- [x] `date` - display date
- [x] `echo` - display anything
- [x] `exit` - exit terminal
- [x] `export` - save variables
- [x] `expr` - solve math expressions
- [x] `help` - list commands
- [x] `history` - display session history
- [x] `ls` - list files
- [x] `mkdir` - create folders
- [ ] `mv` - move files and folders
- [x] `pwd` - display current working directory
- [x] `rm` - remove files and folders
- [x] `touch` - create files
- [x] `uname` - display basic system info
- [x] `unzip` - unzip archives
- [x] `zip` - zip files

### Custom Commands

You can make more commands by simply creating a swift file within your project in this format.

```swift
import Swish

// Replace `example` in class name
class _command_`example`: Command {

    // Initialize the name and usage
    required init(_ session: ShellSession) {
        super.init(session)
        name = "example"
        usage = "usage: example [-s] ..."
    }

    // Parse arguments and execute command.
    // Return an exit code:
    // 0: successful
    // 1: failure
    // more can be found in its documentation
    override func execute(_ args: [String]) -> Int { /* ... */ }

    // Implement auto-completion functionality
    override func tab(_ args: [String], count: Int) -> String { /* ... */ }
}
```

Finally, add the custom command into Swish like so:
```swift
Shell(root: Shell.documentsURL).session(user: "user", hostname: "swish", uuid: UUID().uuidString) { (exists, session) in
    self.swish = Swish(session: session)
    
    // Integrate custom commands
    let commands = [
        _command_example.init(session),
    ]
    self.swish.commands.append(contentsOf: commands)
}
```

## File structure

Swish creates the following directories when a session is created for the first time at the given root path.

```
root
├─ home/
   ├─ user/
```

## Dependencies

- [Zip](https://github.com/marmelroy/Zip)
    - `zip` command
    - Used to zip files and folders.
- [DDMathParser](https://github.com/davedelong/DDMathParser)
    - `expr` command
    - Used to solve mathematical expressions.

## License

Swish is available under the AGPL license. See the LICENSE file for more info.

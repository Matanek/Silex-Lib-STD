# StreamChild

[Retour au catalogue des recettes](../README.md).

```sx
use STD.Console
use STD.Process
use STD.Subprocess
use STD.Text.UTF8

func child() {
    if line = Console.read_line() { Console.write("child:" + line) }
}

func parent(executable:str) {
    let command = Subprocess.SpawnCommand(
        executable:executable,
        arguments:["--stream-child"],
        current_directory:null,
        inherit_environment:true,
        environment:[]
    )
    match Subprocess.spawn(command) {
        failure(error) => { panic(error.operation + ": " + error.detail) }
        success(var process) => {
            let input = UTF8.bytes("ready\n")
            let view = @input[0:input.count()]
            match process.write_standard_input(view) {
                failure(error) => { panic(error.operation + ": " + error.detail) }
                success(count) => { assert(count == input.count(), "complete child input") }
            }
            match process.close_standard_input() {
                failure(error) => { panic(error.operation + ": " + error.detail) }
                success => {}
            }
            var running = true
            while running {
                match process.next_event(1000) {
                    failure(error) => { panic(error.operation + ": " + error.detail) }
                    success(event) => {
                        if value = event {
                            match value {
                                output(stream, bytes) => {
                                    let output = @bytes[0:bytes.count()]
                                    match UTF8.decode(output) {
                                        failure(error) => { panic("child output is not UTF-8") }
                                        success(text) => { Console.write(text) }
                                    }
                                }
                                exited(status) => { running = false }
                            }
                        }
                    }
                }
            }
        }
    }
}

func main() {
    match Process.arguments() {
        failure(error) => { panic(error.detail) }
        success(arguments) => {
            if arguments.count() > 1 && arguments[1] == "--stream-child" { child() }
            else {
                match Process.executable_path() {
                    failure(error) => { panic(error.detail) }
                    success(executable) => { parent(executable) }
                }
            }
        }
    }
}
```

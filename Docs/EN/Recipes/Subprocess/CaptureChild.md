# CaptureChild

[Back to the recipe catalog](../README.md).

```sx
use STD.Console
use STD.Process
use STD.Subprocess
use STD.Text.UTF8

func print_output(output:Subprocess.Output) {
    let bytes = @output.standard_output[0:output.standard_output.count()]
    match UTF8.decode(bytes) {
        failure(error) => { panic("Child output was not UTF-8") }
        success(text) => { Console.write(text) }
    }
}

func parent(executable:str) {
    let command = Subprocess.Command(
        executable:executable,
        arguments:["--child"],
        current_directory:null,
        inherit_environment:true,
        environment:[],
        standard_input:[],
        maximum_output_bytes:4096
    )
    match Subprocess.run(command) {
        failure(error) => { panic(error.operation + ": " + error.detail) }
        success(output) => { print_output(output) }
    }
}

func start_parent() {
    match Process.executable_path() {
        failure(error) => { panic(error.detail) }
        success(executable) => { parent(executable) }
    }
}

func dispatch(arguments:str[]) {
    if arguments.count() > 1 && arguments[1] == "--child" {
        print("Hello from the child process")
    } else {
        start_parent()
    }
}

func main() {
    match Process.arguments() {
        failure(error) => { panic(error.detail) }
        success(arguments) => { dispatch(arguments) }
    }
}
```

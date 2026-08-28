# ScopedEnvironment

[Back to the recipe catalog](../README.md).

```sx
use STD.Subprocess
use STD.System
use STD.Text.UTF8

func print_output(output:Subprocess.Output) {
    let bytes = @output.standard_output[0:output.standard_output.count()]
    match UTF8.decode(bytes) {
        failure(error) => { panic("Environment output was not UTF-8") }
        success(text) => { print(text) }
    }
}

func run_env(executable:str, arguments:str[]) {
    let command = Subprocess.Command(
        executable:executable,
        arguments:arguments,
        current_directory:null,
        inherit_environment:false,
        environment:[Subprocess.EnvironmentChange.set("SILEX_MODE", "production")],
        standard_input:[],
        maximum_output_bytes:4096
    )
    match Subprocess.run(command) {
        failure(error) => { panic(error.operation + ": " + error.detail) }
        success(output) => { print_output(output) }
    }
}

func main() {
    match System.platform() {
        windows => { run_env("C:\\Windows\\System32\\cmd.exe", ["/C", "set SILEX_MODE"]) }
        macos => { run_env("/usr/bin/env", []) }
        linux => { run_env("/usr/bin/env", []) }
    }
}
```

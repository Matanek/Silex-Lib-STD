# InspectRuntime

[Back to the recipe catalog](../README.md).

```sx
use STD.Process

func main() {
    print("Process id: $(Process.id())")
    match Process.current_directory() {
        failure(error) => { panic(error.detail) }
        success(directory) => { print("Working directory: $(directory)") }
    }
    match Process.arguments() {
        failure(error) => { panic(error.detail) }
        success(arguments) => {
            print("Arguments: $(arguments.count())")
            for argument in arguments { print("- $(argument)") }
        }
    }
}
```

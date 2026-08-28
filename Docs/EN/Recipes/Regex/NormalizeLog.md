# NormalizeLog

[Back to the recipe catalog](../README.md).

```sx
use STD.Regex

func emphasize(found:@Regex.Match) str { return "[$(found.text())]" }

func main() Result<void,str> {
    let levels = try Regex.compile(
        "\\b(error|warning)\\b",
        Regex.Options(case_insensitive:true)
    ) else error "the log-level pattern is invalid"
    let separators = try Regex.compile("\\s*[,;]\\s*")
        else error "the separator pattern is invalid"

    print(levels.replace_all("warning: disk; ERROR: network", emphasize))
    for field in separators.split("render, audio;network") { print(field) }
    return Result<void,str>.success()
}
```

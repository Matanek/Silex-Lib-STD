# ExtractContacts

[Back to the recipe catalog](../README.md).

```sx
use STD.Regex

func main() Result<void,str> {
    let contact = try Regex.compile(
        "(?<account>[A-Za-z0-9._%+-]+)@(?<domain>[A-Za-z0-9.-]+\\.[A-Za-z]{2,})"
    ) else error "the contact pattern is invalid"

    let message = "Write to hello@silex-lang.org or team@example.com."
    for found in contact.find(message) {
        if account = found.capture("account") {
            if domain = found.capture("domain") {
                print("$(account.text()) at $(domain.text())")
            }
        }
    }
    return Result<void,str>.success()
}
```

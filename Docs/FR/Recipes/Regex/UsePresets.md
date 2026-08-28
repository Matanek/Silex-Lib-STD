# UsePresets

[Retour au catalogue des recettes](../README.md).

```sx
use STD.Regex

func main() {
    let text = "Contact team@silex-lang.org from 192.168.1.20."

    if email = Regex.Presets.email().first(text) {
        print("email: ", email.text())
    }

    if address = Regex.Presets.ipv4().first(text) {
        print("IPv4: ", address.text())
    }

    print("whole IPv6: ", Regex.Presets.ipv6().match("2001:db8::38"))
    print("one digit: ", Regex.Presets.digit().match("７"))
}
```

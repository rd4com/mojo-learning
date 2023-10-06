## Version of mojo when written: v0.3.0

[The new mojo release](https://docs.modular.com/mojo/changelog.html#v0.3.0-2023-09-21) now makes it possible to use default and named arguments:
```
fn greet(times: Int=1, message: String = "!!!"):
    for i in range(times):
        print("Hello " +message)

fn main():
    greet()
    greet(message="mojo")
    greet(times=2)
```

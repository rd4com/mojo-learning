# 🏳️ make test builds using a custom flag
In mojo, it is possible to do it through programming!

For serious testing, the assert functions provided mojo standard library should be used instead.

*Note: testing is very important, and that code have not been tested. not ready for use*

```python
from sys.param_env import is_defined

alias testing = is_defined["testing"]()

#let's do colors for fun!
@always_inline
fn expect[message:StringLiteral ](cond:Bool):

    if cond: 
        #print in green
        print_no_newline(chr(27))
        print_no_newline("[42m")
    else: 
        #print in red
        print_no_newline(chr(27))
        print_no_newline("[41m")

    print_no_newline(message)
    
    #reset to default colors
    print_no_newline(chr(27))
    print("[0m")

fn main():
    @parameter
    if testing:
        print("this is a test build, don't use in production")

    @parameter
    if testing:
        expect["math check"](3==(1+2))
        #should print "math check in green"
```
### pass testing "flag":
```mojo build myfile.mojo -D testing```

```-D customised=1234``` is also possible, 
see [param_env](https://docs.modular.com/mojo/stdlib/sys/param_env.html)






# 🏳️ make test builds using a custom flag
In mojo, it is possible to do it trough programming!

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
        print(chr(27),end='')
        print("[42m",end='')
    else: 
        #print in red
        print(chr(27),end='')
        print("[41m",end='')

    print(message,end='')
    
    #reset to default colors
    print(chr(27),end='')
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






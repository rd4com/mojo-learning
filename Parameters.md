## Version of mojo when written: v0.3.0

>Parameters represents compile time values. [Mojo documentation: parameterization](https://docs.modular.com/mojo/programming-manual.html#parameterization-compile-time-metaprogramming)

`[T:AnyType]` anything passed to theses need to be a compile time value.

```
alias debug_mode = True

fn example[T:AnyType](arg:T):

    @parameter
    if T==Float64:
        print("Float64")
        print(rebind[Float64](arg))
    
    @parameter
    if T==Int:
        print("Integer")
        print(rebind[Int](arg))
    
    @parameter
    if debug_mode:      
        #if true the code will be "included" at comile time.
        # the if statement will never run again during runtime
        print("debug")
```
`alias` is a compile time value [Mojo documentation: alias](https://docs.modular.com/mojo/programming-manual.html#alias-named-parameter-expressions)

`[T:AnyType]` are parameters!

`@parameter if` is runned at compile time.


TODO: more on rebind [Mojo documentation: rebind](https://docs.modular.com/mojo/stdlib/builtin/rebind.html)

*If there is errors or incorrect things please  git-push/issue/message*
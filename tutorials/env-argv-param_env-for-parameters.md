# 🦜 env, argv and param_env (for alias)
> with v0.5.0
## Overview
```env```: defined in the os ENV

```argv```: get command-line arguments

```param_env```: for alias, available at compile time

## param_env
They are retreived when mojo build the program.

So they can be used to do compile-time logic.

```mojo build -D build_message="now faster with simd!" -D simd_width=8 app.mojo```
```python
from sys.param_env import is_defined,env_get_int,env_get_string

fn get_width() -> Int:
    @parameter
    if is_defined["simd_width"]():
        @parameter
        if env_get_int["simd_width"]() > simdwidthof[DType.uint8]():
            # simd_width too big, default to max
            return simdwidthof[DType.uint8]()
        else:
            return env_get_int["simd_width"]()
    else:
        return 1

alias simd_width:Int = get_width()

#shorter way for default value:
alias build_message:StringLiteral = env_get_string["build_message","none"]()

fn main():
    @parameter
    if build_message != "none":
        print("build message:",build_message)

    var v = SIMD[DType.uint8,simd_width]()
    print(v)
```
Start the program:

```./app```

Output:

    build message: now faster with simd!
    [0, 0, 0, 0, 0, 0, 0, 0]
## env
It is not "only a mojo thing", it is widely used by operating systems and apps.

##### Example:
```python
from os import getenv

fn main():
    var k = getenv(name= "ENV_VARIABLE_NAME", default= "none")
    if k == "none":
        print("it is default value")
        return
```


## args
> ⚠️ the example do not include error checking, so don't use it as it is

Build the app: ```mojo build app.mojo```

    ./app "The number is" 3
    ./app "The number is" 4
They are retrieved each time we run the program.

```python
from sys import argv

fn main() raises:
    var arguments = argv()
    let size = len(arguments)

    var message = arguments[1]
    #convert to an integer
    var the_number:Int = atol(arguments[2])

    print(message,the_number)
```

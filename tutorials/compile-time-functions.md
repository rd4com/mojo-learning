# 🪄 making compile time functions: same as the runtime ones
> with v0.4.0

Execute a function at comptime
```python
#can be used both during comptime and runtime
fn squared(n:Int)->Pointer[Int]:
    var tmp = Pointer[Int].alloc(n)
    for i in range(n):
        tmp.store(i,i*i)
    return tmp

def main():

    #alias: during comptime
    alias n_numbers = 5
    alias precaculated = squared(n_numbers)

    for i in range(n_numbers):
        print(precaculated.load(i))
    
    precaculated.free()
```

#### what is the code doing
Returns a pointer with pre-calculated values during compilation and using it at runtime.
#### how to call squared() during runtime
By not using alias.
```python
# using var instead of alias
var precaculated = squared(n_numbers)
```

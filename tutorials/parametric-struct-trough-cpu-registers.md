# 🏃 (SPEED) Parametric struct through CPU registers.

> with v24.1.0

Some types are store in the ram. each time we access the ram it takes time.

The reason for accessing the ram is to retrieve a value, or change it, even makes a copy of it (example: pointers).

Ram is slow compared to cpu registers.  (just like storage hard-drive is slower than ram).

The speed to access a CPU register vs RAM is significantly higher,

let's make a struct that is passed trough cpu-register for  higher speed!

An example of such type is an Integer, but mojo pave the way for designing way more sophisticated types!



Let's implement a naive parametric Tuple type that can be passed trough registers.

Note: mojo comes with builtin register passables Tuple types already.

# Naive tuple passed trough registers



```python
@register_passable("trivial")
struct naive_register_tuple[T_FIRST:AnyRegType,T_SECOND:AnyRegType]:
    var first:T_FIRST
    var second:T_SECOND
    
    fn __init__(inout self, arg_one:T_FIRST,arg_two:T_SECOND):
        self.first = arg_one
        self.second= arg_two
    
    fn mutate_first(inout self,val:T_FIRST):
        self.first = val
    
    fn mutate_second(inout self,val:T_SECOND):
        self.second = val

    
fn main():

    #explicitely specify the types:
    var tmp = naive_register_tuple[Bool,Bool](True,True)
    
    #with struct parameter deduction:
    var val = naive_register_tuple(True,1)
    
    #mutate first value:
    val.mutate_first(False)
    
    #get the type from the parameters:
    var my_vec = DynamicVector[val.T_FIRST]()
    my_vec.push_back(val.first)
    
    #get a copy:
    var val2 = val

    #get fields individually
    let val_first = val2.first
    let val_second:val2.T_SECOND = val2.second
```

Many methods could be implemented on top of a register_passable struct.

This is great for meta-programming and productive/creative implementations.

Examples:
- ```__getitem__``` to create a ```value[index]``` type of access
- ```__add__``` to perform ```new_value = value_a+value_b```
- many more

### AnyRegType

> It represent any register-passable mojo data type.

When making a register-passable struct,

the types of the members must be register-passable aswel.

This is why the struct made in the above example are parametrized:

```python
struct naive_register_tuple[T_FIRST:AnyRegType,T_SECOND:AnyRegType]:
    var first:T_FIRST
    var second:T_SECOND
```





### trivial
It means that we can get a copy of a value and that we can move it.

There is no need to implement thoses methods. (```copyinit```, ```moveinit```, ```takeinit```, ```del```)

Think about it, theses are just "sequences of bytes" that can be copied as they are from one register to another.

A way to think about thoses is in term of "bags of bits" (see mojo documentation).



> Note: that decorator is subject to reconsiderations

see [Documentation: trivial types](https://docs.modular.com/mojo/programming-manual.html#trivial-types)

# A new tool in the 🧰 !
One clear benefit is the speed.

Another significant benefit is that it creates the opportunity to design/implement new/different types.

Theses will becomes more popular as mojo evolve and people start to create hardware specific types.


It also **reconcile performance and user-friendlyness** in a significant manner .





---

&nbsp;


See [Contributions](/contribute.md) for ideas, drafts, tutorials, corrections.



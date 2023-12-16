# 🧬 Parameters, Alias, Struct parameter deduction, more

> with v0.5.0

⚠️ Some examples are "minimal and simple", no safe checks are done.

It is to better illustrate concepts and not clutter the mind, make sure follow good practices and safe coding in your implementations.

Let's learn how to parametrize!




# Start of the tutorial
> Parameters are compile-time values.

That example also covers "Struct parameters deduction". 

It is very useful, try to practice playing with it in order to remember and understand it.

Notice how the deduction "works its way" up the struct and fill the blanks.

It feels like the arguments types defines the parameters of the struct, and not the other way around.

Increased productivity, less screen space used, less repetitive coding:

```python
@value
struct Point3D[XT:AnyType,YT:AnyType,ZT:AnyType]:
    var x:XT
    var y:YT
    var z:ZT

    fn __init__(inout self, x:XT ,y:YT,z:ZT):
        self.x = x
        self.y = y
        self.z = z

# 4️⃣. use parameters of an argument inside the function signature:
fn to_list_literal(arg:Point3D)-> ListLiteral[arg.XT,arg.YT,arg.ZT]:
    return ListLiteral(arg.x,arg.y,arg.z)

fn main():

    #1️⃣ Explicit struct parameters:
    var my_point_d = Point3D[Int64,Int64,Int64](1,2,3)
    var my_point_e = Point3D[Int64,Float64,Int64](1,2.5,3)
    
    #2️⃣ Struct parameters deduction 
        #XT, YT, ZT deduced from argument passed:

    var my_point_a = Point3D(1, 2, 3)         #Int64, Int64, Int64

    var my_point_b = Point3D(1.0, 2.0, 3.0)   #Float64, Float64, Float64
    
    var my_point_c = Point3D(1, 2.5, 3)       #Int64, Float64, Int64

    #3️⃣ Re-use the parameters of an instance of Point3D
    var some:my_point_c.YT = 1.0 #my_point_c.YT is a type (Float64)

    print(to_list_literal(my_point_a)) # [1, 2, 3]
    print(to_list_literal(my_point_c)) # [1, 2.5, 3]
```
#### see [Changelog: v0.5.0-2023-11-2](https://docs.modular.com/mojo/changelog.html#v0.5.0-2023-11-2)
- Function argument input parameters can now be referenced within the signature of the function
- Mojo now supports struct parameter deduction
---

### Automatic parameterization of functions
see [Documentation](https://docs.modular.com/mojo/programming-manual.html?q=parameter#automatic-parameterization-of-functions)

Our ```take_dynamic_vector()``` don't take parameters for arg, but DynamicVector is parametric.

The long form version could look like this:
```python
fn take_dynamic_vector[T:AnyType](arg:DynamicVector[T]) -> T:
```

Mojo will create theses for us in order to be more productive.

It is important to be aware of it in order to understand the language.

```python
fn take_dynamic_vector(arg:DynamicVector) -> arg.type:
    let tmp: arg.type = arg[0] #first element of vector
    return tmp

fn main(): 
    var tmp_a = DynamicVector[Int64]()
    var tmp_b = DynamicVector[Float64]()
    var tmp_c = DynamicVector[Bool]()

    tmp_a.push_back(1)
    tmp_b.push_back(1.5)
    tmp_c.push_back(True)

    let a:Int64 = take_dynamic_vector(tmp_a)
    let b = take_dynamic_vector(tmp_b)

    print(a,b)

    #parameters are known at compile time
    #type is a parameter of DynamicVector

    let d:tmp_c.type = False #tmp_c.type == Bool
    let e = take_dynamic_vector(tmp_c)
    print(d==e)
    
```
---
### "Pulling" parameters when needed:
Note that we refer to the parameter of arg, inside the function signature itself.
```python
fn simd_to_dtype_pointer(arg:SIMD)->DTypePointer[arg.type]:
    var tmp = DTypePointer[arg.type].alloc(arg.size)
    # just to demonstrate unroll, 
    # simd_store is probably way faster:
    @unroll
    for i in range(arg.size):
        tmp.store(i,arg[i])
    return tmp

fn simd_to_static_tuple(arg:SIMD)->StaticTuple[arg.size,SIMD[arg.type,1]]:
    var tmp = StaticTuple[arg.size,SIMD[arg.type,1]]()
    
    #Can be unrolled, because arg.size is known at compile time.
    #Parameters of simd: SIMD[TYPE,SIZE]
    
    @unroll
    for i in range(arg.size):
        tmp[i]=arg[i]
    return tmp
```
see [Changelog: july-2023](https://docs.modular.com/mojo/changelog.html#july-2023) for more on ```@unroll```

Compiler time constant value (alias or parameters for example) is required to unroll a loop.

---
### Capture dynamic value in function and pass it as a parameter
It is unsafe for now (v0.5), until model the lifetime of captured value by reference.

see [Documentation: parameter decorator](https://docs.modular.com/mojo/programming-manual.html#parameter-decorator)

Here is an introduction in order to get familiar with it:
```python
fn take_parameter[f: fn() capturing -> Int]():
    let val = f()
    print(val)

fn main():

    #will be captured as a reference
    var val = 0
    
    @parameter
    fn closure()->Int:
        return val #captured here
    
    for i in range(5):
        val = i
        take_parameter[closure]()

    _ = val #extend lifetime manually
    #if not extended, would be cleaned at last use.
```
---
### Compile time if statement
It is an if statement that runs at compile time.

The benefit is that only the live branch is included into the final program.

see [Documentation: parameter if](https://docs.modular.com/mojo/programming-manual.html#parameterization-compile-time-metaprogramming)



```python
alias use_simd:Bool = SIMD[DType.uint8].size > 1

fn main():
    @parameter
    if use_simd == True:
        print("This build uses simd")
    else:
        print("This build do not uses simd")
```
A traditional if statement that run at runtime is executed each time.

That one is executed only one time during the compilation.

What is inside the block of the if statement is included in the program if condition is met.

It introduce a form of conditional compilation.

Note that any "compile-time ready" function can be used in the if statement.

---
### alias
For compile time constants, 

they can be passed as parameters because they are compile-time known.

```python
fn main():
    alias size = 4
    alias DT = DType.uint8
    var value = SIMD[DT,size](0)
    print(value.size==size)

    #create an alias to the print_no_newline function
    alias say = print_no_newline

    say("hello world")
```
They can also be used "like define in C"
```python
alias TYPE_OF_INT = Int64

fn get_vector()->DynamicVector[TYPE_OF_INT]:
    return DynamicVector[TYPE_OF_INT]()

fn my_add(a:TYPE_OF_INT,b:TYPE_OF_INT)->TYPE_OF_INT:
    return a+b
```
Because an alias is "compile-time", it can store the result of a compile time computation:
```python
fn squared(a:Int) -> Int:
    return a*a

fn main():
    alias pre_calculated_during_compilation = squared(3)
    var calculated_during_runtime = squared(3)
    print(pre_calculated_during_compilation) #9

    alias squared_again_during_compilation = squared(pre_calculated_during_compilation)
    print(squared_again_during_compilation) #81
```
At compile time, it is possible to allocate heap memory and materialize it for runtime use.

See [Changelog: august-2023](https://docs.modular.com/mojo/changelog.html#august-2023)

```python
fn get_squared[stop_at:Int=10]() -> DynamicVector[Int]:
    var tmp = DynamicVector[Int]()
    for i in range(stop_at):
        tmp.push_back(i*i)
    return tmp

fn main():
    alias the_compile_time_vector = get_vector[stop_at=100]()
    var materialized_for_runtime_use = the_compile_time_vector
```


---
#### Parameter default value and keyword
Parameters can have default values and be referred by keyword.

The ones that have default values need to be defined after the ones that don't (order).
- ```example[no_default:Int, got_default:Int=1]```


```python
fn get_vector[VT:AnyType = Int64]()->DynamicVector[VT]:
    return DynamicVector[VT]()

fn main():
    var vec = get_vector()
    vec.push_back(1)

    var vec2 = get_vector[VT=Int32]()
    vec2.push_back(1)
```
---
    

### Overloading: same name, different types.
Overloading can be done on parameters and functions/methods.
```python
fn take_arg[arg:Float64]():
    print("float64", arg)

fn take_arg[arg:Int64]():
    print("Int64", arg)

fn main():
    alias a:Float64 = 1.0
    alias b:Int64 = 1
    take_arg[a]()
    take_arg[b]()
```

See:
- [Documentation: overloading on parameters](https://docs.modular.com/mojo/programming-manual.html#overloading-on-parameters)

- [Documentation: overloading methods and functions](https://docs.modular.com/mojo/programming-manual.html#overloaded-functions-and-methods)


---
&nbsp;


This is a work in progress and will get improved and expanded,


[Corrections and contribution](/contribute.md)!



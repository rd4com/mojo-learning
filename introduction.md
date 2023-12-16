
# 🔦 Introduction
### Modules: code reuse and organisation
***mylib.mojo***
```ruby
struct something:
    var x:Int
    var y:Int
    fn __init__(inout self a:Int,b:Int):
        self.x = a
        self.y = b
fn myfunc(inout s:something):
    s.y = s.x*2
```
***app.mojo***
```python
import mylib    #or from mylib import something
fn myfunc():
    print("hello world")
fn main():
    var x:mylib.something = mylib.something(0,0) 
    mylib.myfunc(x)     #keep the scope clean
    myfunc()
```
**It has great potential for web applications.**

Trough the package modularity, it is possible to share data structures and logic between two apps, example: 

- Front end
- Back end

Mojo could become the standard in making AI web services.

As of today, mojo cannot produce web-assembly, but, probably will, in the future.

*note: [Packaging]() is related to modules.*

### import and use any python module or file
***mylib.py***
```python
def print_from_mylib(arg):
    print(arg)
```
***app.mojo***
```python
from python import Python
fn main() raises:
    let time = Python.import_module("time")
    let mylib = Python.import_module("mylib")
    print(time.monotonic_ns())
    mylib.print_from_mylib(time.monotonic_ns())
```
### object with small footprint
Object comparable to those of Python, Javascript, Ruby, Lua, out of the box.
```python
#Around 38kb
fn take_object(o: object):
    print(o)
fn main() raises:
    var obj = object("hello world")
    obj = object([]) #change to a list
    obj.append(object(123))
    obj.append(object("hello world"))
    take_object(obj)
```
Fits into tiny space, potentially WASM and microcontrollers.

Huge demand (stats from today, the 29th September of 2023):
- [tinygo](https://github.com/tinygo-org/tinygo) (13.5k stars)
- [microptython](https://github.com/micropython/micropython) (17.3k stars)

Note: Objects do have types and can be type-checked.


### encapsulation with static methods
```python
struct helpers:
    @staticmethod
    fn is_even(value: Int) -> Bool:
        return ((value&1)==0)

fn main():
    var x:Int = 2
    print(helpers.is_even(x))   #keep the scope clean
```
### From prototype to production using the same language

It can of great help to peoples that need to react to changes in their industry quickly.

It is useful to be able to explore new ideas without using a lot of time.

Before:
```python
from python import PythonObject
def create_list()->PythonObject:
    return PythonObject([])

def push_list(l:PythonObject ,o:PythonObject):
    l.append(o)

def main():
    mylist = create_list()
    push_list(mylist,123)
    push_list(mylist,"hello world")
    print(mylist)
```
After:
```python
struct myList[T:AnyType]:
    var data: Pointer[T]
    fn push(inout self, o: T):
        ...
```


### use the hardware efficiently in a few lines of codes
The amount of knowledge, and the lines of codes required to do this in other languages can be different:
- SIMD operations
- Use all cores in a safe manner
- Optimisations


```python
var python_result = numpy.linspace(0, 255,256)          
var simd_mojo_array = SIMD[DType.float64,256]()

for x in range(256):
    simd_mojo_array[x]=python_result[x].to_float64()
simd_mojo_array = math.cos(simd_mojo_array*(3.14*2.0/256.0))

print(simd_mojo_array)
#could vectorize and run in parallel with more data, see mojo documentation and examples
```
see [Using the Mojo 🔥 Visual Studio Extension 🚀](https://www.youtube.com/watch?v=KYEAiTBbNT8) where Jack Clayton also shows the vectorize features provided by mojo
### named arguments with default values

```python
fn print_times(t:Int= 1,text:String = "default"):
    for i in range(t):
        print(text)

fn main():
    print_times(text="hello world")
    print_times()
```
### compile time logic
```python
alias debug_build = 0
def main():
    var x:Int = 0
    @parameter
    if debug_build == 1:
        print(x)
    #debug_build is 0, print(x) is not in the build!
```
### variadic arguments
```python
fn my_func(*args_w: String):
    var args = VariadicList(args_w)
    for i in range(len(args)):
        print(__get_address_as_lvalue(args[i])) #it will get better

fn main():
    my_func("hello","world")
```
see [roadmap & sharp edges: no-safe-value-references](https://docs.modular.com/mojo/roadmap.html#no-safe-value-references) 
### multiples functions with same name and different signatures
```python
fn my_func(o:String):
    print("it is a string")

fn my_func(o:Int):
    print("it is an integer")

fn main():
    my_func(1)
    my_func("hello world")
```
### different constructors with automatic resolve
```python
struct my_struct:
    var x: Int
    fn __init__(inout self, other: Int):
        self.x = other
    fn __init__(inout self, other: Float64):
        self.x = other.to_int()
   
def main():
    var i:Int = 123
    var f:Float64 = 123.0
    
    var a:my_struct = i
    var b:my_struct = f
```
### memory under control with the [ASAP](https://docs.modular.com/mojo/programming-manual.html#behavior-of-destructors)(as soon as possible) policy
```python
fn main():
    var a:String = "hello"
    print(a)
    var x = 123
    _ = a #arg's memory reclaimed(freed) after the last use (here)
    print(x)
```
### ownership system
```python
fn take_ownership(owned arg: Int):
    print(arg)

fn change_value(inout arg: Int):
    arg = 1 
    
fn main():
    var data:Int = 0
    take_ownership(data^)
    change_value(data)               # error: use of uninitialized value 'data'
```
arg in take_ownership is owned, so the function is ready to take ownership of what is passed.

the ownership of data is given/transfered using the ^ suffix

### meta-programming, increased expressive power
```python
struct my_struct:
    var x: Int
    def __init__(inout self, value:Int):
        self.x = value
    def __call__(inout self):
        print("my value is",String(self.x))
    def __getitem__(inout self, key:String):
        for i in range(self.x):
            print(key)
    def __getitem__(inout self, key:Int):
        for i in range(key):
            print("hello world")
def main():
    var x = my_struct(2)
    x()         #print: my value is 2
    x["hello"]  #print 2 times: "hello"
    x[2]        #print 2 times: "hello world"
```
### generic types
```python
struct my_struct[T:AnyType]:
    var data: T
    fn __init__(inout self, value: T):
        self.data = value
    fn replace(inout self, new_value: T):
        self.data = new_value

fn main():
    var x = my_struct[Int](1)
    x.replace(2)
```
### protection, safety
my_func_protected: *arg is borrowed(a copy), changes made won't affect "the original".*

my_func: *arg is inout and changes will be reflected on "the original".*
```python
fn my_func_protected(borrowed arg: Int):
    print(arg)

fn my_func(inout arg: Int):     #inout
    arg=2     #reflected on the original

def main():
    var x:Int = 1
    my_func_protected(x)
    my_func(x)
    print(x)    #my_func changed x to 2
```
*Note: If not defined as inout or owned, values are borrowed by default in mojo 0.3.0, so borrowed can be omitted.*
### performance: loop unrolling and inlining
```python
@always_inline
fn print_and_increment(inout x: Int):
    print(x)
    x+=1

fn main():
    var i = 0
    @unroll
    while i<3:
        print_and_increment(i)
```
*becomes*
```python
fn main():
    var i = 0
    print(i)
    i+=1
    print(i)
    i+=1
    print(i)
    i+=1
```    
The program is faster by not doing ```if i<3``` on each iteration and by not having to jump into print_and_increment. 

It also become bigger but the point is that this is a choice.





### can be used with Jupyter notebook
People use notebooks to do research, presentations, exploration and more.

see [Mojo playground](https://playground.modular.com/)

It is possible to use the notebook from vscode.


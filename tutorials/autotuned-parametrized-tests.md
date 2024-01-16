# 🪄🔮 Autotuned parametrized tests
```Autotune``` is a feature related to ```alias```,

aliases are used in parameters ```struct MyType[ParamSimdSize:Int]: ...```,

they are used by mojo to provide more expressivity, versatility, safety and performance!

Mojo have to process them before the program runs, so they cannot use dynamic values.

It seem like a limiting thing, but it is quite the opposite!

For example, by specifying a Movable parameter, any movable types can be passed as an argument.

&nbsp;

```SIMD``` is a type that can be parametrized over it's ```DTYPE``` and ```SIZE```,

A type could be ```uint8```, ```float64```, and many more! The ```SIZE``` could be ```1,2,4,8,16,32,..```.

So there are many combination of thoses parameters.

This is just an example, aliases can be assigned many things, even pointers, types, floats..

Additionally, it is possible to write usual mojo functions that returns a value, to both aliases and var.

&nbsp;

# ❤️‍🔥 Autotuning

In order to select the values of aliases, auto-tuning can be used to do so by programming in mojo.

The idea is to provide a set of valid options, and write some logic.

That logic is then followed by mojo, and it will determine wich value should be assigned!

And multiple parameters can be autotuned in the same ```@adaptive``` decorated function.

Autotune allows to search in that big space and pick the values that are the most desired.


 



&nbsp;


# 🌌 The process of evaluation

It is a function that receives all the versions of the ```@adaptive``` decorated one,

this is where the logic can be written in order to "benchmark" each version.

A common way is to measure time 🔥, it is up to the imagination too!

For example, each version can be called: ```var f = functions[2](1,MyStruct(1.5))```

The return value can be used, to "score" the performance for example.

If the result of that version is "good", the index (```2```) can be saved in a variable. 

Once "what is best" is determined, either by measuring time or another logic,

the index of the final version is retured as an integer:

```return 2```, for example.



On the receiving hand, the chosen function is available in an alias for use !

&nbsp;

Autotune allow the programmer iterate that "big space" of potential alias values.

Here is an example of using autotuning in order to perform tests on a parametrized type ⬇️

&nbsp;

# 🧶 Example: Testing with all the possible parameters

The algorithmic part of the code is not quite user-friendly,

theses operations can be replaced by a simple ones in an easy to understand way.

The algorithm itself is simple, only the implementation looks difficult.

This is a situation where testing is very usefull, especially testing for all the possible parameters.

By having thoses kind of tests, it can be easier to progressively re-implement the algorithm,

while having the tests there to check, if it still works like before or not! 



```python
from autotune import autotune, search

@adaptive
fn Tests():
    alias width_to_use = autotune(1,2,4,8,16,SIMD[DType.uint8].size) 
    var instance = Small[width_to_use]()
    print("Simd width:"+ str(width_to_use))
    return instance.TestsBitSet()

fn evaluator(funcs: Pointer[fn()->None], total: Int) -> Int:
    print("🪄🔮 Autotuned parametrized tests: "+str(total))
    for t in range(total):
        let current = funcs.load(t)
        current()
    return 0

fn run_tests():
    alias res: fn()->None
    search[
        fn()->None,
        VariadicList(Tests.__adaptive_set),
        evaluator -> res
    ]()

def main():
    #var x = Small()
    #x.ArrayBitSet[31](1)
    #var res:Int = x.ArrayBit[31]()
    #print(res)
    run_tests()

@register_passable
struct Small[SIZE:Int=SIMD[DType.uint8].size](Stringable):
    alias DT = DType.uint8 #not change, require re-implementing
    alias StorageType = SIMD[Self.DT,Self.SIZE]
    alias SizeOfArrayBits = Self.StorageType.size*sizeof[Self.DT]()*8
    alias MostSignificantBitPosition = Self.SizeOfArrayBits -1

    var data: Self.StorageType

    fn __init__()-> Self: return Self{
        data: Self.StorageType(0),
    }

    fn __str__(self)->String: return "todo"
    
    fn ArrayBit[index:Int](self)->Int:
        alias constrained_ArrayBit_ArrayBit = index < Self.SizeOfArrayBits
        constrained[constrained_ArrayBit_ArrayBit,"index too big"]()
        var tmp = self.data[Self.StorageType.size-1-(index>>3)]
        tmp &= (tmp&(1<<(index&7))) 
        return (tmp>0).cast[DType.bool]().to_int()
    
    fn ArrayBitSet[index:Int](inout self,value:Int):
        alias constrained_ArrayBit_ArrayBit = index < Self.SizeOfArrayBits
        constrained[constrained_ArrayBit_ArrayBit,"index too big"]()
        var b = self.data[Self.StorageType.size-1-(index>>3)]
        b&=(255^(1<<(index&7))) 
        b|=(SIMD[Self.DT,1](value).cast[DType.bool]().cast[Self.DT]()<<(index&7))
        self.data[Self.StorageType.size-1-(index>>3)]=b
    
    fn TestsBitSet[ManualTests:Bool=False](self):
        var tmp = Self()
        @parameter
        if ManualTests:
            print("\n\nTests:")
            _=tmp.ArrayBit[self.MostSignificantBitPosition]()
            tmp.data[0]=128
            print("    \tExpected\t Result")
            print("1\tTrue\t\t",(tmp.ArrayBit[Self.MostSignificantBitPosition]()>0))
            tmp.data[0]=0
            print("2\tFalse\t\t",(tmp.ArrayBit[Self.MostSignificantBitPosition]()>0))
            tmp.data[0]=64
            print("3\tTrue\t\t",(tmp.ArrayBit[Self.MostSignificantBitPosition-1]()>0))
            tmp.data[0]=1
            print("4\tTrue\t\t",(tmp.ArrayBit[Self.MostSignificantBitPosition-7]()>0))
            tmp.data[0]=0
            print("5\tFalse\t\t",(tmp.ArrayBit[Self.MostSignificantBitPosition-7]()>0))
            tmp.ArrayBitSet[0](1)
            print("6\tTrue\t\t",(tmp.ArrayBit[0]()>0))
            print("7\tTrue\t\t",(tmp.data[Self.StorageType.size-1]==1))
            tmp.ArrayBitSet[0](0)
            tmp.ArrayBitSet[4](1)
            print("8\tTrue\t\t",(tmp.ArrayBit[4]()>0))
            print("9\tTrue\t\t",(tmp.data[Self.StorageType.size-1]==16))

            @parameter
            if Self.StorageType.size > 1:
                tmp = Self()
                tmp.ArrayBitSet[8](1)
                print("10\tTrue\t\t",(tmp.ArrayBit[8]()>0))
            
            @parameter
            if Self.StorageType.size > 2:
                tmp.ArrayBitSet[24](1)
                print("11\tTrue\t\t",(tmp.ArrayBit[24]()>0))
                print("12\tTrue\t\t",(tmp.data[Self.StorageType.size-1-3]==1))
                tmp.ArrayBitSet[24+7](1)
                print("13\tTrue\t\t",(tmp.data[Self.StorageType.size-1-3]==129))
                print("14\tTrue\t\t",(tmp.ArrayBit[24+7]()>0))
                tmp.ArrayBitSet[24+7](0)
                print("13\tTrue\t\t",(tmp.data[Self.StorageType.size-1-3]==1))
                print("14\tTrue\t\t",(tmp.ArrayBit[24+7]()==0))

            tmp = Self()
            tmp.data = Self.StorageType.splat(255)
            tmp.ArrayBitSet[0](0)
            print("15\tTrue\t\t",(tmp.data[Self.StorageType.size-1]==254))

            print(tmp.data)

        alias size_dt = math.bitwidthof[Self.DT]()
        var tmp_result = SIMD[DType.bool,size_dt*SIZE].splat(False)
        var instance = Self()
        
        @parameter
        fn more_tests[B:Int]():
            @parameter
            fn fn_b[b:Int]():
                instance.ArrayBitSet[B*size_dt+b](1)
                var result = instance.ArrayBit[B*size_dt+b]()
                tmp_result[B*size_dt+b]=result
            unroll[size_dt,fn_b]()
        unroll[SIZE,more_tests]()
        
        print_no_newline("\tUnrolled tests(" + str(size_dt*SIZE) + "):")
        if tmp_result.reduce_and():
            print_no_newline("\t✅🔥")
        else: print_no_newline("\t❌")
        print("")
        print("\t" + str(instance.data))
```
#### output:
```python
🪄🔮 Autotuned parametrized tests: 6
Simd width:1
	Unrolled tests(8):	✅🔥
	255
Simd width:2
	Unrolled tests(16):	✅🔥
	[255, 255]
Simd width:4
	Unrolled tests(32):	✅🔥
	[255, 255, 255, 255]
Simd width:8
	Unrolled tests(64):	✅🔥
	[255, 255, 255, 255, 255, 255, 255, 255]
Simd width:16
	Unrolled tests(128):	✅🔥
	[255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255]
Simd width:32
	Unrolled tests(256):	✅🔥
	[255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255]

```

Theses tests are parametrized by:
```python
alias width_to_use = autotune(1,2,4,8,16,SIMD[DType.uint8].size) 
```

&nbsp;

# 🪇 Explanation of the algorithm

A ```SIMD``` vector of 16 ```uint8``` is created, for example. There are ```8*16=128``` bits available in total.

Let's say that we want to set the bit number ```65``` to ```1```, and use ```65``` as an index.

Each time a multiple of ```8``` is passed, the index of the ```uint8``` vector  is increased by one!

**Until 64 is reached, then the remainder is ```1```.**

So the bit to set is the first one of the vector number 8.

```65 modulus 8```, the algorithmic part is that simple, but the implementation looked complicated.


Example for position 17: 
- index 2: ```floor(17.0 / 8.0)``` ➡️ ```17>>3```
- remains 1: ```17%8``` ➡️ ```17&7``` 

&nbsp;

## 🩳 The ```Constrained``` function
> Compile time checks that the condition is true.

> see [Documentation: Constrained](https://docs.modular.com/mojo/stdlib/builtin/constrained.html)

The index of the position is entered as a parameter, that way it is possible to raise compile time errors!

Because the size of the ```SIMD``` was used as a parameter, 

aswell as the ```type```, thoses safeguards can be implemented!

&nbsp;

## 🌗 ```@parameter if```
> see [Documentation: Parametric if statement](https://docs.modular.com/mojo/manual/decorators/parameter.html#parametric-if-statement)

It is like an if statement, but the assertion of the outcome is done during the compilation.

```python
@parameter
if Self.StorageType.size > 2:
    ...
```
```Self.StorageType``` is a parameter,

if it's size is above ```2```, additional tests can be made!

For example, a ```SIMD``` of size```2``` contains only index 0️⃣ and 1️⃣ to be tested, but not above.

&nbsp;

## 🌀 ```unroll```
Similar to a while loop, but with parameters.

That way, incrementing ```i``` is not required, because mojo just unroll every iteration.

The iteration is faster that way!

```python
@parameter
fn more_tests[B:Int]():
    @parameter
    fn fn_b[b:Int]():
        instance.ArrayBitSet[B*size_dt+b](1)
        var result = instance.ArrayBit[B*size_dt+b]()
        tmp_result[B*size_dt+b]=result
    unroll[size_dt,fn_b]()
unroll[SIZE,more_tests]()
```
The equivalent for loop:

```python
for B in range(SIZE):
    for b in range(size_dt):
        instance.ArrayBitSet[B*size_dt+b](1)
        var result = instance.ArrayBit[B*size_dt+b]()
        tmp_result[B*size_dt+b]=result
```

&nbsp;

## ```alias```

They can be passed to parameters, note the reference to ```Self.DT```:
```python
struct Small[SIZE:Int=SIMD[DType.uint8].size](Stringable):
    alias DT = DType.uint8
    alias StorageType = SIMD[Self.DT,Self.SIZE]
```
Aliases are compile time constants, they can even receive the result of function!

```python
alias size_dt = math.bitwidthof[Self.DT]()
```
The parameters are really powerful, they make it possible to do all thoses expressive things.

&nbsp;

## ```@parameter``` functions
> see [Documentation: Parametric closure](https://docs.modular.com/mojo/manual/decorators/parameter.html#parametric-closure)
```python
fn main():
    var x=1
    @parameter
    fn increment[B:Int]():
        x+=B
    increment[1]()
    print(x)
```
Output: ```2```

This is a parametric capturing closure,

variables used inside of it can be modified, even if they were declared outside of it.

&nbsp;

### 🔥 They can be passed as parameter to other functions

```python
fn Incrementor[f:fn()capturing->None]():
    f()

fn main():
    var x=1
    @parameter
    fn increment():
        x+=1
    
    Incrementor[increment]()
    print(x)
```

&nbsp;

&nbsp;

# 🪄 Hope it was usefull ! ✨
### Thanks to contributors and to people from the chat community for the support 👍

This small tutorial can contains errors, feel free contribute corrections.

Make sure to go to the official documentation website, this is where true magic is learned!
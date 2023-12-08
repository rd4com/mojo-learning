

# 📋 Traits: accept any types that comply to requirements


> Tutorial updated to reflect [Changelog: v0.6.0 (2023-12-04)](https://docs.modular.com/mojo/changelog.html#v0.6.0-2023-12-04)

>Traits introduced in [Changelog: v0.6.0 (2023-12-04)](https://docs.modular.com/mojo/changelog.html#v0.6.0-2023-12-04)

&nbsp;



We already know that a type(struct) can implement some methods, and have some fields.


What if multiples types implement the same method signature but differently ? 

Can we sort of group them?

Yes, it is partially why traits are usefull.


A trait is like a checklist, it allows mojo to verify if a type comply with a list of things.

For now, only methods can be "added" to that check list.

That checklist can then be used to accept different types as argument for example.

*(It is not exacly a checklist, but it helps to think about it that way, in order to start understanding)*



&nbsp;
# 🟢 Introduction (Let's start from the beginning)

A value/variable has to comply some requirements in order to be passed as an argument(```()```).

Usually, they have to be of a pre-determined type (example: ```Int64```).

Here is an example(```Int64```):
```python
fn MyFunction(argument: Int64):
    pass
fn main():
    var MyValue: Int64 = 1
    MyFunction(MyValue)
```

```MyValue``` is passed as an argument to ```MyFunction```,

there are no errors because the type of ```MyValue``` comply to the requirements.

The requirement is simple: the  value passed as an argument has to be an ```Int64```!

&nbsp;

What if we want to be able to pass a value of either ```Int64``` or ```Int32``` type ?

We can specify thoses requirements in a new trait!

But let's choose an existing trait for now! (```Intable```)

&nbsp;



The trait ```Intable``` requires the types who want to comply with it:
- An ```__int__(self)->Int``` method implemented in their struct

Both ```Int64``` and ```Int32``` comply with that trait.



&nbsp;
 

Traits have to be specified in the parameter zone (```[]```)

```python
fn MyFunction[Requirements: Intable](argument: Requirements):
    print(int(argument))
    
fn main():
    var MyValue: Int64 = 2
    MyFunction(MyValue)

    var MyValue2: Int32 = 1
    MyFunction(MyValue2)
```
We can now call the ```__int__()``` method on the argument ! 

It is what ```int(argument)``` does, and the ```Intable``` trait was made for ```__int__()```.

&nbsp;

Make sure to understand that we can now call the ```__int__()``` method on the argument.

The type of the value passed to the function as an argument have to comply to ```Intable```.

In order to comply, the type have to implement ```__int__(self)->Int```

Sorry for the repetition, it is important.




&nbsp;

## two arguments:
```Python
fn MyFunction[R_1: Intable,R_2: Intable](first: R_1, second: R_2) -> Int:
    return (int(first)+int(second))
    
fn main():
    var result = MyFunction(Int64(2),Int32(1))
    print(result)
```
It is necessary to have two sets of the same requirements,

because the arguments could be of  differents ```Intable``` compliant types.

One could be ```Int64``` and the other ```Int32```.

Each argument is related to its corresponding parameter ```[]```.

&nbsp;

#### with different requirements:
```python
fn Repeat[R_1: Intable, R_2: Stringable](amount: R_1, message: R_2):
    for i in range(int(amount)):
        print(str(message))

fn main():
    Repeat(2,"Two times")
```
In order to comply with the ```Stringable``` trait,

A struct have to implement one method:
- ```fn __str__(self) -> String``` 

&nbsp;

# Creating a new type
```Int64``` is a type, and types are designed in a ```struct``` block.

Let's first create a non interesting type, and slowly get to traits!

&nbsp;
### 1️⃣
```python
struct MyType:
    var val: Int

fn main():
    var MyValue = MyType(1)
```

```error: 'MyType' does not implement any '__init__' methods in 'var' initializer```

### 2️⃣✅

```python
struct MyType:
    var val: Int
    fn __init__(inout self, argument: Int):
        self.val = argument

fn main():
    var MyValue = MyType(1)
```

### 3️⃣
```python
struct MyType:
    var val: Int
    fn __init__(inout self, argument: Int):
        self.val = argument

fn main():
    var MyValue = MyType(1)
    var TryCopy = MyValue
```

```error: value of type 'MyType' cannot be copied into its destination```

### 4️⃣✅
```python
struct MyType:
    var val: Int
    fn __init__(inout self, argument: Int):
        self.val = argument
    fn __copyinit__(inout self, other: Self):
        self.val = other.val

fn main():
    var MyValue = MyType(1)
    var TryCopy = MyValue
```

### 5️⃣ Let's implement the ```Intable``` requirements
```python
struct MyType:
    var val: Int
    fn __init__(inout self, argument: Int):
        self.val = argument
    fn __copyinit__(inout self, other: Self):
        self.val = other.val 
    fn __int__(self)->Int : return self.val 

fn MyFunction[Requirements: Intable](argument: Requirements):
    print(int(argument))

fn main():
    var MyValue = MyType(1)
    MyFunction(MyValue)
```
```error: invalid call to 'MyFunction': callee expects 1 input parameter, but 0 were specified```



### 6️⃣✅
Let's specify that the ```struct``` implement ```Intable``` inside the parenthesis ```()``` !
```python
struct MyType(Intable): #()
    var val: Int
    fn __init__(inout self, argument: Int):
        self.val = argument
    fn __copyinit__(inout self, other: Self):
        self.val = other.val
    fn __int__(self)->Int : return self.val
    

fn MyFunction[Requirements: Intable](argument: Requirements):
    print(int(argument))

fn main():
    var MyValue = MyType(1)
    MyFunction(MyValue)
```
### 7️⃣✅ Let's implement ```Stringable``` trait's requirements
Also specify that the ```struct``` implement ```Stringable```.

*Because a type can implement multiple traits.*

```python
struct MyType(Intable,Stringable): #()
    var val: Int
    fn __init__(inout self, argument: Int):
        self.val = argument
    fn __copyinit__(inout self, other: Self):
        self.val = other.val
    fn __int__(self)->Int : return self.val
    fn __str__(self)->String: return String(self.val)

fn MyFunction[Requirements: Stringable](argument: Requirements):
    print(str(argument))

fn main():
    var MyValue = MyType(1)
    MyFunction(MyValue)
```


### 8️⃣✅ Let's regroup the traits under a new trait
A trait can inherit multiples traits, they are specified inside the parenthesis ```()```
```python
trait MyTrait(Intable,Stringable): #()
    ... 

struct MyType(MyTrait):
    var val: Int
    fn __init__(inout self, argument: Int):
        self.val = argument
    fn __copyinit__(inout self, other: Self):
        self.val = other.val
    fn __int__(self)->Int : return self.val
    fn __str__(self)->String: return String(self.val)

fn MyFunction[Requirements: MyTrait](argument: Requirements):
    print(str(argument))

fn MyFunctionTwo[Requirements: Stringable](argument: Requirements):
    print(str(argument))

fn main():
    var MyValue = MyType(1)
    MyFunction(MyValue)    #👍
    MyFunctionTwo(MyValue) #👍
```
```trait MyTrait(Intable,Stringable)``` is inheriting from ```Intable``` and ```Stringable```.

the three dots ```...``` are required for now to keep the block not empty.
### 9️⃣✅ Make it smaller

```python
trait MyTrait(Intable,Stringable):
    ...

@value
struct MyType(MyTrait): #()
    var val: Int
    fn __int__(self)->Int : return self.val
    fn __str__(self)->String: return String(self.val)

fn MyFunction[Requirements: MyTrait](argument: Requirements):
    print(str(argument))
    print(int(argument))

fn main():
    var MyValue = MyType(1)
    MyFunction(MyValue)
```
the ```@value``` struct decorator synthesize 3 methods:

- ```__copyinit__()```
- ```__moveinit__()```
- ```__init__()```

Two of theses comply to traits requirements:

- ```Movable```
- ```Copyable```

*see [Documentation: @value](https://docs.modular.com/mojo/manual/decorators/value.html)*

&nbsp;


### 1️⃣0️⃣✅ Specify compliance to ```Movable``` and ```Copyable```

```python
trait MyTrait(Intable,Stringable,Movable,Copyable):
    ...

@value
struct MyType(MyTrait): 
    var val: Int
    fn __int__(self)->Int : return self.val
    fn __str__(self)->String: return String(self.val)

fn MyFunction[Requirements: Movable](argument: Requirements):
    let some = argument^


fn main():
    var MyValue = MyType(1)
    MyFunction(MyValue)
```

### 1️⃣1️⃣✅ Adding new requirements

```python
trait Incrementer(Movable,Copyable):
    fn Increment(inout self) -> Int: ...

@value
struct IntCounter(Incrementer):
    var val: Int
    fn Increment(inout self) -> Int:
        self.val += 1
        return self.val

fn main():
    var C1 = IntCounter(0)
    for i in range(2): print(C1.Increment())
```
The three dots ```...``` are required for now to keep the method block not empty.

In the future, we might be able to provides a default implementation there.

(see [Documentation: using traits](https://docs.modular.com/mojo/manual/traits.html#using-traits))




### 1️⃣2️⃣✅ The power of traits

In the begining, the only requirement available was type equality. (```Ìnt64```)

It was only possible pass a value of that type to that function argument:

```fn double(argument: Int64)```

&nbsp;

After that, the ```Intable``` trait made it possible to pass values of multiple types.

we passed both ```Ìnt64``` and ```Ìnt32``` values to:

```python
fn MyFunction[Requirements: Intable](argument: Requirements):
    print(int(argument))
```



&nbsp;

We now have a new trait named ```Ìncrementer```,

Let's create another type that comply with it and pass both to a function!

```python
trait Incrementer(Movable,Copyable):
    fn Increment(inout self) -> Int: ...

@value
struct IntCounter(Incrementer): 
    var val: Int
    fn Increment(inout self) -> Int:
        self.val += 1
        return self.val

@value
struct PythonCounter(Incrementer): 
    var val: PythonObject
    fn Increment(inout self) -> Int:
        try:
            self.val += 1
            return int(self.val)
        except e: return 0

fn IncrementAnyCounter[R:Incrementer](inout AnyCounter:R):
    print(AnyCounter.Increment())

fn main():
    var C1 = IntCounter(0)
    var C2 = PythonCounter(0)
    for i in range(2):
        IncrementAnyCounter(C1)
        IncrementAnyCounter(C2)
```




### 1️⃣3️⃣✅ Beyond function argument

Let's make a trait parametrized type. (```[]```)

The new type will be able to have a field that comply to ```Incrementer```. 


```python
trait Incrementer(Movable,Copyable):
    fn Increment(inout self) -> Int: ...

@value
struct IntCounter(Incrementer): #()
    var val: Int
    fn Increment(inout self) -> Int:
        self.val += 1
        return self.val

@value
struct PythonCounter(Incrementer): #()
    var val: PythonObject
    fn Increment(inout self) -> Int:
        try:
            self.val += 1
            return int(self.val)
        except e: return 0

@value
struct AnyCounter[T:Incrementer]:
    var val: T

fn main():
    var C1 = AnyCounter(IntCounter(0))
    var C2 = AnyCounter(PythonCounter(0))
    for i in range(2):
        print(C1.val.Increment(), C2.val.Increment())
```

&nbsp;

# Making a struct that implement an existing trait

### The [DynamicVector](https://docs.modular.com/mojo/stdlib/utils/vector.html#dynamicvector) type 



> 🔥 will now call del on its elements when del is called on it! 🔥



parametrized on a trait: ```[T:CollectionElement]```.





### The [CollectionElement](https://docs.modular.com/mojo/stdlib/utils/vector.html#collectionelement) ```trait``` requirements:

- ```__copyinit__()``` (Copyable)
- ```__moveinit__()``` (Movable)
- ```__del__()``` (Destructable)



&nbsp;

### Designing a struct that comply with the ```CollectionElement``` trait
It is fantastic, 

the ```@value``` struct decorator can synthesize the required methods of that specific trait.

That decorator synthesize exacly 3 functions and 2 of them are thoses.

- ```__copyinit__()```
- ```__moveinit__()```

It will also sythesize an initializer:
- ```__init__()```



*see [Documentation: @value](https://docs.modular.com/mojo/manual/decorators/value.html)*


```python
@value
struct my_struct(CollectionElement):
    var x:Int
    var y:String

fn main():
    var vector = DynamicVector[my_struct]()
    vector.push_back(my_struct(1,"hello"))
    vector.push_back(my_struct(2,"world"))
    print(vector[0].x,vector[0].y)
```
You might have noticed that ```@value``` do no synthesize ```__del()__```,

and that the ```CollectionElement``` trait requires an implementation of it. (```Destructable```)

it is because **every traits inherit from the ```Destructable``` trait**.

and mojo automatically adds a no-op ```__del__()``` to types that don't implement one.

see [Documentation: Destructable](https://docs.modular.com/mojo/manual/traits.html#the-destructable-trait)





&nbsp;

# 💄 Traits:  another example!


```ruby
trait CanWalk:
    fn walk(self): ...
trait CanSwim:
    fn swim(self): ...
trait CanDoBoth(CanWalk,CanSwim): #Inherit from both
    ...


@value
struct turtle(CanDoBoth):
    var name:String
    fn walk(self): print(self.name, " is walking")
    fn swim(self): print(self.name, " is swimming")

@value
struct dolphin(CanSwim):
    var name:String
    fn swim(self): print(self.name, " is swimming")


fn call_walk[T:CanWalk](w:T):
    w.walk()

fn call_swim[T:CanSwim](s:T):
    s.swim()

fn call_both[T:CanDoBoth](b: T):
    b.walk()
    b.swim()


fn main():
    let d = dolphin("🐬")
    let t = turtle("🐢")

    #🐢 can do both
    call_both(t) #👍
    call_swim(t) #👍 
    call_walk(t) #👍

    #🐬 dolphin can swim
    call_swim(d)
```

🐢 implemented the requirements of the inherited traits of ```CanDoBoth``` 

🐢 comply to ```CanWalk``` and ```CanSwim``` aswell !





&nbsp;

# Multiple features together!

```rust
@value
struct Concept(CollectionElement):
    var name:String

trait Learner:
    fn learn(inout self, c: Concept): ...

trait Teacher:
    fn teach[L:Learner](self, inout other: L): ...

@value
struct Human(Learner,Teacher):
    var Brain: DynamicVector[Concept]
    fn learn(inout self,c: Concept):
        self.Brain.push_back(c)
    fn teach[L:Learner](self, inout other: L):
        for something in range(len(self.Brain)):
            other.learn(self.Brain[something])
    fn __init__(inout self): self.Brain = DynamicVector[Concept]()

@value
struct AI(Learner,Teacher):
    var DigitalBrain: DynamicVector[Concept]
    fn learn(inout self,c: Concept):
        self.DigitalBrain.push_back(c)
    fn teach[L:Learner](self, inout other: L):
        for something in range(len(self.DigitalBrain)):
            other.learn(self.DigitalBrain[something])
    fn __init__(inout self): self.DigitalBrain = DynamicVector[Concept]()
    
fn TransferKnowledge[T:Teacher,L:Learner](from_:T , inout to_:L):
    from_.teach(to_)

fn main():
    var h = Human()
    h.learn(Concept("First concept"))
    h.learn(Concept("Second concept"))
    h.learn(Concept("Third concept"))
    
    var a = AI()
    TransferKnowledge(h,a)
    
    var h2 = Human()
    TransferKnowledge(a,h2)

    for i in range(3):
        print(h2.Brain[i].name)
```
 

&nbsp;

*In the future, we might be able to provide fields and default methods implementations to traits!*

*But don't worry, it is already very powerfull and liberative!*



*(see [Documentation: Traits](https://docs.modular.com/mojo/manual/traits.html#using-traits))*


&nbsp;

# Traits and ```@staticmethod```
see [Documentation: traits can require static methods](https://docs.modular.com/mojo/manual/traits.html#traits-can-require-static-methods)

This is a very expressive feature, here is an example:

```python

trait MathImplementation:
    @staticmethod
    fn double_int(a:Int)->Int: ...

struct First(MathImplementation):
    @staticmethod
    fn double_int(a:Int)->Int:
        return a*2

struct Second(MathImplementation):
    @staticmethod
    fn double_int(a:Int)->Int:
        return a<<1

fn double_with[T:MathImplementation=First](arg:Int)->Int:
    return T.double_int(arg)

fn main():
    let result = double_with[First](1)
    let result2 = double_with[Second](1)
    print(result)
    
    #Default implementation 
    print(double_with(1)) # 🔥   
```
There are more ways to select a default implementation:
- [alias](https://docs.modular.com/mojo/manual/parameters/#alias-named-parameter-expressions)
- [param_env](https://docs.modular.com/mojo/stdlib/sys/param_env.html)
- [@parameter if](https://docs.modular.com/mojo/manual/decorators/parameter.html#parametric-if-statement)

```@staticmethod``` is usefull to make namespace types that dont need an instance for example.








# Traits that comes with mojo
A list with clear explanations are available in: [Documentation: built-in traits]()

- ```len(my_struct_instance)``` Sized
- ```int(my_struct_instance)``` Intable
- ```str(my_struct_instance)``` Stringable

Along with:
- ```CollectionElement``` DynamicVector
- ```Copyable``` *\_\_copyinit\_\_()*
- ```Destructable``` *\_\_del\_\_()*
- ```Movable``` *\_\_moveinit\_\_()*
    
    

The list will probably grow as mojo evolve!


&nbsp;

# 📬  


This tutorial is a community effort ❤️ , it can contains error and will be updated.



&nbsp;

Make sure to navigate the official site of mojo, wich contains the best ressources for learning!

Mojo also have it's documentation available on it's github [repository](https://github.com/modularml/mojo/tree/main/docs) !









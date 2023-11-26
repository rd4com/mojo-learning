

# 🔥 With blocks: with my_struct(1) as v (parametric/minimal/raise)


> with v0.5.0

The with blocks are similar to the ones in python in many aspects.

In mojo, it is possible to parametrize the struct.

This is just one distinction, there are probably more and more to come!



### A. Minimal example
That example cover a new supported feature introduced in [Changelog: 2023-10-05](https://docs.modular.com/mojo/changelog.html#v0.4.0-2023-10-05)

- support an ```__enter__``` method without implementing support for an ```__exit__``` method
```python
@value
struct my_struct[T:AnyType]:
    var value: T
    
    fn __init(inout self,arg:T):
        self.value = arg
    
    fn __enter__(owned self) -> T:
        return self.value
        #__del__() called on self here

fn main():

    #struct parameter deduction:
    with my_struct(1.5) as value:
        print(value)

    #explicitely specify type:
    with my_struct[Bool](True) as value:
        print(value)
```

Note the absence of an ```__exit__()``` method in that  example. 

self is "consumed" in the ```__enter__(owned self)->T```

```__del()__``` is called on self after the last use of it.


 see [Mojo documentation:ASAP](https://docs.modular.com/mojo/programming-manual.html#behavior-of-destructors) for more on why it is called after it's last use.

There is also a small tutorial on ASAP inside this repository.

&nbsp;

### B. Error handling and Exit
That example cover some features introduced in
[Changelog: week-of-2023-04-24](https://docs.modular.com/mojo/changelog.html#week-of-2023-04-24).

#### enter the with block, and provide value of type T
```fn __enter__(self) -> T:```

#### exit the with block without error
```fn __exit__(self):```

#### error got raised inside the with block:
```fn __exit__(self, err: Error) -> Bool:```


```python
@value
struct my_struct[T:AnyType]:
    var value: T
    
    fn __init(inout self,arg:T):
        self.value = arg
    
    #Return a value to be used by the with block
    fn __enter__(self) -> T:
        return self.value
    
    fn __exit__(self):
        print("🏖️ exit with success")

    #For error handling
    fn __exit__(self, err: Error) -> Bool:
        print("❌ Error 'received' by __exit__ : ",err)

        if err._message() == "Error in with block":
            #Let's consider it handled by returning True.
            print("✅ Handled in exit")
            return True
            
        #If return False, it means the error was not handled here
        #the error will be re-propagated/re-thrown 
        return False

fn main() raises:
    
    try:
        with my_struct(1.5) as value:
            print(value)
            #raise Error("Error in with block") 
            raise Error("Another error") 
    
    except err:
        #The error got re-thrown here
        print("❌ Error 'received' by main : ",err)

        #Lets consider it handled.
        print("✅ Handled in main")

        #Program will continue, below in the main function

    print("Main: all good")
```

Depending on wich error is thrown (see the commented one),

the program produce one of theses two outputs:
#### A:
```
1.5
❌ Error 'received' by __exit__ :  Error in with block
✅ Handled in exit
Main: all good
```
#### B:
```
1.5
❌ Error 'received' by __exit__ :  Another error
❌ Error 'received' by main :  Another error
✅ Handled in main
Main: all good
```

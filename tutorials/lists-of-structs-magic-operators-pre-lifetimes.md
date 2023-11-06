# 🤹 making lists of structs with magic operators (pre-lifetimes)


> with v0.5

*note: ⚠️ there could be bugs in the code or errors, please [contribute corrections](/contribute.md)*




&nbsp;





In mojo for now, there is something called *magic operators* .

Theses are used for unsafe references until the day we gonna use lifetimes.


There are a lot of conversation on the github repo of mojo about the lifetimes, proposals and a refinement process.

More about it can be read on the website of mojo aswell.




&nbsp;

#### [Roadmap: ownership and lifetimes](https://docs.modular.com/mojo/roadmap.html#ownership-and-lifetimes) for more on lifetimes

#### [Documentation: Pointer](https://docs.modular.com/mojo/stdlib/memory/unsafe.html#pointer) the tutorial uses pointers

&nbsp;


### ```__get_lvalue_as_address()``` 
  - see [Roadmap: shap edges](https://docs.modular.com/mojo/roadmap.html#sharp-edges)
  
  -  returns the address of a instance
  - ```
    var x = 1
    var pointer = __get_lvalue_as_address(x)
    __get_address_as_lvalue(pointer)=2
    var with_copyinit = __get_address_as_lvalue(pointer)
    _ = x #extend lifetime
    ```


### ```__get_address_as_lvalue()```
  - documentation in [Roadmap: shap edges](https://docs.modular.com/mojo/roadmap.html#sharp-edges)
  - ```__get_address_as_lvalue(address) = other_instance ``` 
    - will call ``` __del__()``` on existing value at the address (cannot contains nothing)
  - get an copy instance trough ```__copyinit__```:
    - ```var x = __get_address_as_lvalue(address)```



### ```__get_address_as_owned_value()``` 
  - introduced in [Week of 2023-04-17](https://docs.modular.com/mojo/changelog.html#week-of-2023-04-17)
  -  return the "original" instance as owned
  -  ```__del()__``` will be called on the "original" instance when last used
  -  require extra attention for proper use! (unsafe)


### ```__get_address_as_uninit_lvalue()``` 
  - introduced in [Week of 2023-04-17](https://docs.modular.com/mojo/changelog.html#week-of-2023-04-17)
  -  act like a placement new
  -  ```__get_address_as_uninit_lvalue(address) = instance```
     -  address should be allocated
     -  address should not already contain a value
     -  will **not** call ``` __del__()``` on value at the address 
     

&nbsp;
#### Example: list of struct
> ⚠️ this code have not been tested, require more work
```python
@value
struct a_struct:
    var x:Int
    var y:Int

struct storage:
    var data: Pointer[a_struct]

    fn __init__(inout self,capacity:Int):
        self.data = self.data.alloc(capacity)

    fn __moveinit__(inout self,owned other:Self):
        #see tutorial on moveinit
        #__del__() will not be called on "other"
        #with takeinit, __del__() is called on it
        self.data=other.data
    
    fn store(inout self, i:Int,value:a_struct):
        #placement new on the offset
        #will not call __del()__ if something was there
        __get_address_as_uninit_lvalue(self.data.offset(i).address) = value
    
    fn get(inout self, i:Int)->a_struct:
        #returns a __copyinit__() instance, not the original
        return __get_address_as_lvalue(self.data.offset(i).address)
    
    fn replace(inout self, i:Int,value:a_struct):
        #will call __del__() on the previous value
        __get_address_as_lvalue(self.data.offset(i).address) = value
        
    fn __del__(owned self):
        self.data.free()

def main():
    var collection = storage(capacity=2)
    
    for i in range(10):
        collection.store(0,a_struct(0,1))
        collection.store(1,a_struct(2,3))

    for i in range(2):
        let res = collection.get(i)
        print(res.x,res.y)
        
    collection.replace(0,a_struct(1,1))

    for i in range(2):
        let res = collection.get(i)
        print(res.x,res.y)
    
```
Lifetimes can be manually extended if needed:
```
var x = 1
#unsafe reference code
_ = x #extended lifetime
```
see the [ASAP](https://docs.modular.com/mojo/programming-manual.html#behavior-of-destructors). (call del on last use of the instance)

> one revision on Nov 6 2023

[contribute corrections](/contribute.md)
## tutorial in the process of revision and correction
[contribute corrections](/contribute.md)


&nbsp;

&nbsp;
# 🤹 references until lifetimes: powerfull


> with v0.5

*note: ⚠️ there could be bugs in the code or errors in the tutorial, please [contribute corrections](/contribute.md)*




&nbsp;



For persons that are used to C/(other awesome languages)/lowlevel pointers, there is something called magic operators:
-  provide the ability to store memory only types in pointers
-  [create self referencing types](#example-self-referencing-type)
-  create vectors of memory only types

&nbsp;

#### see [Roadmap: ownership and lifetimes](https://docs.modular.com/mojo/roadmap.html#ownership-and-lifetimes) to learn about the status of lifetimes in mojo
(with lifetimes, it will be different, more user-friendly and more awesome ❤️)

&nbsp;



### ```__get_lvalue_as_address()``` 
  - see [Roadmap: shap edges](https://docs.modular.com/mojo/roadmap.html#sharp-edges)
  
  -  the ownership of the original instance will be transfered to it
  -  return the address of an instance
  -  the original is freed when ```__del()__``` is called on owned value:
     -  ```_ = __get_address_as_owned_value(address)```


### ```__get_address_as_lvalue()```
  - documentation in [Roadmap: shap edges](https://docs.modular.com/mojo/roadmap.html#sharp-edges)
  - mutate the original: 
    - ```__get_address_as_lvalue(address) = "mutate the original" ``` 
  - create a copy:
    - ```var x = __get_address_as_lvalue(address)```



### ```__get_address_as_owned_value()``` 
  - introduced in [Week of 2023-04-17](https://docs.modular.com/mojo/changelog.html#week-of-2023-04-17)
  -  return the original instance
  -  when ```__del()__``` is called on the instance, the memory pointed by the address is freed

&nbsp;
#### Example
> ⚠️ this code have not been tested, require more work
```python
struct memory_only_type:

    var storage:Pointer[String]
    var have_the_responsibility_to_free_the_memory:Bool

    fn __init__(inout self):
        self.storage = Pointer[String]()
        self.have_the_responsibility_to_free_the_memory = False
    
    fn set(inout self, owned str:String):
        
        #the argument comes as owned (ownership transfered here)

        #if already contains something, need to be freed
        if self.have_the_responsibility_to_free_the_memory:

            #dereference as owned value, gets "the original"
            let original = __get_address_as_owned_value(self.storage.address)

            #last use here, __del__ will be called on it
            _ = original^       
            self.have_the_responsibility_to_free_the_memory = False
        
        self.storage.address = __get_lvalue_as_address(str)
        self.have_the_responsibility_to_free_the_memory = True
        
    fn get_value(inout self) raises ->String:
        if self.have_the_responsibility_to_free_the_memory == False:
            raise Error("error: dont contains anything")

        #dereference as a copy, __del__() will be called on the copy
        return __get_address_as_lvalue(self.storage.address)

    fn __del__(owned self):
        if self.have_the_responsibility_to_free_the_memory:
            #dereference as owned value, it gets "the original"
            #__del__ will be called on it
            _ = __get_address_as_owned_value(self.storage.address)

    fn get_value_as_owned(inout self) raises->String:
        if self.have_the_responsibility_to_free_the_memory == False:
            raise Error("dont contains anything")

        #return the original, we should not free it ourselves anymore
        self.have_the_responsibility_to_free_the_memory = False

        let res = __get_address_as_owned_value(self.storage.address)
        return res^ #transfer the ownership
        

fn main():
    var storage = memory_only_type()
    
    try:
        var s = String("hello world")
        storage.set(s^)                 #transfer the ownership
        print(storage.get_value())      #get a copy

        let x = String("hello world 2")
        storage.set(x^)                 #transfer the ownership
        print(storage.get_value())      #get a copy

        #get the original, now storage don't contain anything:
        print(storage.get_value_as_owned())

        #since it don't contains anything, let's raise an error:
        let tmp = storage.get_value()
    except e:
        print(e)
    
```

&nbsp;

#### example: self-referencing type
> ⚠️ this code have not been tested, require more work
```python
@value
struct my_type:
    var ptr: Pointer[my_type]
    var x: Int
    
    fn __init__(inout self,val:Int):
        self.ptr = self.ptr.get_null()
        self.x = val
    
    fn assign(inout self, owned o:my_type):
        self.ptr.address = __get_lvalue_as_address(o)
    
    fn free(inout self):
        _ = __get_address_as_owned_value(self.ptr.address)
    
    fn get_value(inout self)-> my_type:
        return __get_address_as_lvalue(self.ptr.address)
    
    fn mutate_value(inout self,val:Int):
        #get the original value as owned
        var original = __get_address_as_owned_value(self.ptr.address)
        original.x = val
        #store it again so __del__() is not called on it
        self.ptr.address = __get_lvalue_as_address(original)


fn main():
    var s = my_type(0)
    var s_ = my_type(9)
    s.assign(s_^)
    

    s.mutate_value(99)
    s.mutate_value(100)
    
    var result = s.get_value()
    print(result.x)

    s.free()
```



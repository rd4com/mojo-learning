# 🏗️ moveinit and 💿💿 copyinit

> using v0.4.0

Let's have a look at theses features trough an example,

they looks like this :

  - ```fn __copyinit__(inout self, borrowed original: Self)```
    -  original is borrowed and cannot be modified
    -  original live separately and can get deleted later in the program
    -  it provides a way to create a copy of an instance
  - ```fn __moveinit__(inout self, owned original: Self)```
    -  original is owned, ```__del__``` will never be called on it
    -  original can't be used in the program anymore 
    -  **^ transfer suffix** is used to call moveinit
    -  usefull for making sure an instance don't have copies thus is unique

### The illustration:
```python
struct my_type:
    var id:Int
    
    fn __init__(inout self,id:Int):
        self.id=id
        print("init "+String(self.id))

    fn __moveinit__(inout self, owned existing: Self):
        self.id = existing.id
        print("moveinit "+ String(self.id))
        
    fn __copyinit__(inout self, existing: Self):
        self.id = existing.id+1
        print('copyinit '+String(+self.id))
    
    fn __del__(owned self):
        print("del "+String(+self.id))

fn separator():
    print("-------------")

fn main():
    var original = my_type(id=0)    #init 0
    
    separator()

    var copy = original             #copyinit 1
    
    separator()
    
    var still_original = original^  #moveinit 0

    #cannot use original anymore, because moved
    #var other = original
    #would produce an error

```

### Complete output:
    init 0
    -------------
    copyinit 1
    del 1
    -------------
    moveinit 0
    del 0

*Note: del 0 comes from still_original and not original*

### ```var original = my_type(id=0)```
An instance of my_type is created,

it calls ```fn __init__(inout self,id:Int)```

    init 0
### ```var copy = original```
It will call ```fn __copyinit__(inout self, existing: Self)```

We get a copy of it:

    copyinit 1
    del 1
The copy get deleted when it is last used in the code.

We dont use it so it later so it gets deleted here.

### ```var still_original = original^```


the **^ transfer suffix** will call ```__moveinit__(inout self, owned existing: Self)```

we moved original to still_original and took original as ```owned```:
- ```__del__()``` have never been called on original
- del 0 is showed only once
- it is showed whend still_original gets deleted

## why moveinit is important and usefull
We can make sure that an instance have no copies in the program,

when we to pass it to a function, the function could return it:
```python
fn from_owned(owned source:my_type)->my_type:
    #do something or not
    return source
```

Or could assign it to an inout argument:
```python
fn move_to(owned source:my_type,inout to: my_type):
    to = source^ #re transfer it
    #var tmp = source would produce an error
    #source can't be used anymore here
```

It could also be store inside another struct type passed as inout.
```python
fn change_owner(owned some_item:item_type,inout new_owner: owner_type):
    new_owner.owned_item = some_item^
```

### Owned argument does get deleted if not used:
```python
fn from_owned(owned arg:my_type):
    print("not used")
```
```in that case, we don't re-transfer arg, so arg will be deleted.```

```__del__()``` is called at the moment of the last use of the instance.

&nbsp;

*With moveinit, it is easier to enforce safety in the program.*


&nbsp;

> Need further work and help for \_\_takeinit\_\_(), the page will get updated
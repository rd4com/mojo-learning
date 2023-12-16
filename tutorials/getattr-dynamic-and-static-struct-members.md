

# 🏞️ getattr: dynamic and static struct members


> with v0.5.0

```__getattr__()``` is a feature that makes it possible to design flexible and versatile structs in mojo (like other features too). 



It feels like merging the static and the dynamic world.




Theses features are just there when needed, no obligation to use them all the time!

Here is an example, note that ```try:``` and ```except:``` blocks are available in mojo and python!

### my_package.py
```python
def method_from_package():
    return "Called on package"

def package_double_the_value(arg):
    return arg*2

package_value = 123
```

### The struct (in a .mojo or .🔥 file)

Let implement one that can refer to both static and dynamic struct members.

That way, we can do both "mojo things" and "python things" in a seamless manner.


```python
from python import Python

@value
struct PackageHelper:

    var my_package: PythonObject
    var struct_value: Int
    
    def __init__(inout self):
        Python.add_to_path(".")
        self.my_package = Python.import_module("my_package")
        
        self.struct_value = 456

    def method_from_struct(self) -> String:
        return "called on struct"

    def __getattr__(inout self,name:StringLiteral) ->PythonObject:
        return self.my_package.__getattr__(name) 
```
The ```__getattr__()``` implementation is quite small, but is powerful:

If a struct do not define a requested attribute, it will call that function and pass the name of it.

In this implementation, if the attribute is not in the struct, get it from the PythonObject.

That way, it is possible to do ```the_struct_ìnstance.anything``` in a dynamic manner.

Consider this example for more clarity:
  - ```struct_instance.method_defined_in_the_struct()```
    - It works as usual.
  - ```struct_instance.method_not_defined_in_the_struct()```
    - Let the```__getattr__(self, the_name)``` handle that!

### The main function
*(To place just below the mojo struct)*
```python
def main():
    #create an instance
    w = PackageHelper()
    
    #that attribute is defined in the struct
    print(w.method_from_struct())

    #that attribute comes from the PythonObject
    print(w.method_from_package())

    #that attribute is defined in the struct
    print(w.struct_value)

    #that attribute is defined in the PythonObject
    print(w.package_value)

    temp_value = PythonObject(1.0)
    print(w.package_double_the_value(temp_value))
    temp_value = 1.5
    print(w.package_double_the_value(temp_value))
``` 

### Notes
- inside ```def()``` function, ```let``` and ```var``` are optional.
- struct can store PythonObject type instances.
- implicit type
  - temp_value = PythonObject(1.0)
    - temp_value is of PythonObject type
  - temp_value = 1.5
    - instantiated by PythonObject again


```try:``` and ```except:``` blocks can be placed in both ```def()``` and ```fn()``` functions

```__getattr__()``` and ```__setattr()__``` were introduced in [Changelog: Week of 2023-04-03](https://docs.modular.com/mojo/changelog.html#week-of-2023-04-03)

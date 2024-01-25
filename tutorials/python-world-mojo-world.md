# 🔁 Python land and mojo land, PythonObject

[PythonObject](https://docs.modular.com/mojo/stdlib/python/object.html) is a mojo type that can store python objects of any python class (int, list,ndarray..)
- can "travel" through **mojo functions**, as a PythonObject, but can also be passed to **python functions**, as a PythonObject.
- can go back and forth between those two worlds.
- is understood both by python and mojo

### mojo->python
```python
var the_number:Int = 1
var the_py_object = PythonObject(the_number)
```
the_number is a mojo [Int](https://docs.modular.com/mojo/stdlib/builtin/int.html), it is automatically converted to Python object by the method ```__init__(inout self: Self, integer: Int)``` of PythonObject.
### python->mojo
```python
the_number = the_py_object.__index__()
```
```__index__()``` is a method of [PythonObject](https://docs.modular.com/mojo/stdlib/python/object.html)

```to_float64()``` is another one.

### calling python functions
```python
var the_python_list = PythonObject([])
```
The PythonObject is initialized from an empty mojo [ListLiteral](    https://docs.modular.com/mojo/stdlib/builtin/builtin_list.html) by ```__init__[*Ts: AnyType](inout self: Self, value: ListLiteral[Ts])```

the_python_list is now a PythonObject of class list.

```python
the_python_list.append(123)
```
**append is not a method of PythonObject**

- append is a python method of the list class.
- the_python_list is a PythonObject of the list class
- append is in python land and mojo can find it inside the python object and call it!

### the ability to import and use any created python file or "pip" package:
```python
from python import Python
var my_python_file = Python.import_module("my_python_file_name") #no .py needed
my_python_file.my_function([1,2,3]) #mojo will find my_function
```
[import_module](https://docs.modular.com/mojo/stdlib/python/python.html#import_module) return a PythonObject
# Example with many comments:
```python
from python import Python
from python import PythonObject

fn plot_from_mojo(values: PythonObject) raises:
    #require matplotlib package to be installed
    let plt = Python.import_module("matplotlib.pyplot")     
    plt.plot(values) #theses values comes from numpy
                     #that python object class is ndarray: 
                     #print(values.__class__.__name__)
    plt.show()

fn numpy_array_from_mojo() raises -> PythonObject:
    let np = Python.import_module("numpy")      #np is a PythonObject  
                                                #let np:PythonObject...
                                                #import_module returns a PythonObject
    var x = PythonObject([]) #x: PythonObject, class: list 
                             #initialized from an empty list literal https://docs.modular.com/mojo/stdlib/builtin/builtin_list.html
                             #note that [] is a mojo type! (ListLiteral)
    
    var range_size:Int = 256     #Mojo Int!         https://docs.modular.com/mojo/stdlib/builtin/int.html
    #mojo have ranges too, that one is a mojo one   https://docs.modular.com/mojo/stdlib/builtin/range.html
    for i in range(range_size):  #i is a mojo Int 
        #append is a python function, mojo find it inside the PythonObject
        x.append(i) #i get converted to a python object through the __init__ function of PythonObject

    return np.cos(np.array(x)*np.pi*2.0/256.0)
    #np.cos return a python object of class ndarray


def main():     
    #numpy_array_from_mojo is a mojo function that return a PythonObject.       
    var results = numpy_array_from_mojo() 
    #plot_from_mojo is a mojo function that takes a PythonObject.      
    plot_from_mojo(results) 

```

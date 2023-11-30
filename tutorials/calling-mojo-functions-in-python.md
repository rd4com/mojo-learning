# 🔥🐍 calling mojo functions from python
> with 0.4.0

> ⚠️ not ready for use as it is, not tested and have unfreed pointers





Building a wrapper with all thoses features:
- [VariadicList](https://docs.modular.com/mojo/stdlib/utils/list.html#variadiclist) for the arguments types
- [@noncapturing](https://docs.modular.com/mojo/changelog.html#week-of-2023-04-10) to keep the global scope clean
- [import_module](https://docs.modular.com/mojo/stdlib/python/python.html#import_module)
- [PythonObject.\_\_getattr\_\_()](https://docs.modular.com/mojo/stdlib/python/object.html#getattr__)
- [Parametrized function](https://docs.modular.com/mojo/programming-manual.html#defining-parameterized-types-and-functions)
- struct parameter deduction


The function is passed to python using a pointer, as an integer.

*note: it is memory unsafe, not a feature*

#### main.mojo
```python
from python import Python

fn get_wrapper[fsig:AnyType](ret_type:StringLiteral,f:fsig,*args_types:StringLiteral) raises -> PythonObject:
    let ctypes = Python.import_module("ctypes")
    let tmp_ = Pointer[fsig].alloc(1)
    tmp_.store(0,f)
    let tmp = (ctypes.CFUNCTYPE(ctypes.c_void_p)).from_address(tmp_.__as_index())

    let py_obj_argtypes = PythonObject([])

    for i in range(args_types.__len__()):
        py_obj_argtypes.append(ctypes.__getattr__(args_types[i]))
    tmp.argtypes = py_obj_argtypes
    tmp.restype = ctypes.__getattr__(ret_type)
    #note: tmp_ is never freed
    return tmp

def main():

    Python.add_to_path("./")
    let py_mymodule = Python.import_module("python_custom_package")

    @noncapturing
    fn mojo_print(p:Int)->Int:
        print(p)
        return p+1
    
    w = get_wrapper("c_int",mojo_print,"c_int")
    
    py_mymodule.call_mojo_print(w)


    @noncapturing
    fn m_sum(arg:Pointer[Float64],size:Int)->Float64:
        var total:Float64 = 0.0
        for i in range(size):
            total+=arg.load(i)
        return total
    
    w2 = get_wrapper("c_double",m_sum,"c_void_p","c_int")
    py_mymodule.call_sum(w2)
```

#### python_custom_package.py
```python
import numpy as np

def call_mojo_print(mojo_print):
    res = mojo_print(123)
    for i in range(10):
        res = mojo_print(res)


def call_sum(sum):
    elements = 100
    array = np.random.random(elements)
    
    res = sum(array.ctypes.data,elements)
    _ = array
    
    print(res)

    #notes:
    #print(array.dtype)   #float64
    #print(array.strides) #8
```



#### Overview:
- Create a pointer to the mojo function
- Create a PythonObject with ctype imported_module
- load the address as a CFUNCTYPE
- assign the return type and argument types from variadic list
- Pass the PythonObject into python land
- Call the PythonObject from there
- Pointer is left not freed, *need to be freed*


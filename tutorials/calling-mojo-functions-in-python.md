# 🔥🐍 calling mojo functions from python
> with 0.4.0
#### ⚠️ do no use in production, untested code, there might be bugs

the mojo function is using vectorize and SIMD, it could be improved with parallelize.

    mojo benchmark :         0.018098020926117897
    numpy benchmark:         0.025459413998760283
    numpy result   :         24999634.312324334
    mojo result    :         24999634.31232557


The function is passed to python using a pointer, as an integer.

*note: it is memory unsafe, not a feature*


*app.mojo*
```python
from python import Python
from algorithm import vectorize
alias simd_width = simdwidthof[DType.float64]()

fn some_function2(x:DTypePointer[DType.float64],size:Int)->Float64:
    var res = SIMD[DType.float64,simd_width].splat(0.0)
    
    @parameter
    fn vect[groupsize:Int](i:Int):
        @parameter
        if groupsize == simd_width:
            res+=x.simd_load[simd_width](i)
        else:
            res[0]+=x.simd_load[groupsize](i).reduce_add()
    
    vectorize[simd_width,vect](size)
    
    return res.reduce_add()

def main():

    Python.add_to_path("./")
    let py_mymodule = Python.import_module("python_file")

    let func_ptr2 = Pointer[fn(DTypePointer[DType.float64],Int)->Float64].alloc(1)
    func_ptr2.store(some_function2)

    #pass the pointer to the python function
    py_mymodule.call_function2(func_ptr2.__as_index()) #called from python 123
    
    func_ptr2.free()
```
*python_file.py*
```python
import ctypes
import numpy as np
import time

elements = 50000000

def call_function2(address):
    mojo_sum= (ctypes.CFUNCTYPE(ctypes.c_double)).from_address(address)
    array = np.random.random(elements)

    mstart = time.monotonic()
    mojoresult = mojo_sum(ctypes.c_void_p(array.ctypes.data),elements)
    mstop = time.monotonic()
    
    print("mojo benchmark :\t",mstop-mstart)
    
    nstart = time.monotonic()
    result = np.sum(array)
    nstop = time.monotonic()
   
    print("numpy benchmark:\t",nstop-nstart)
    
    print("numpy result   :\t", result)
    print("mojo result    :\t",mojoresult)
```

#### Overview:
- Create a pointer to the mojo function
- Pass the address to python as an integer
- Use ctype to load the address as a c function
- Define the return type and argument types
- Call the function
- Free the pointer

# 🫧 simplify with a wrapper
> ⚠️ not ready for use as it is, not tested and have unfreed pointers

(it is usefull to keep the global scope clean 🧽)

Building a wrapper with all thoses features:
- [VariadicList](https://docs.modular.com/mojo/stdlib/utils/list.html#variadiclist) for the arguments types
- [@noncapturing](https://docs.modular.com/mojo/changelog.html#week-of-2023-04-10) to keep the global scope clean
- [import_module](https://docs.modular.com/mojo/stdlib/python/python.html#import_module)
- [PythonObject.\_\_getattr\_\_()](https://docs.modular.com/mojo/stdlib/python/object.html#getattr__)
- [Parametrized function](https://docs.modular.com/mojo/programming-manual.html#defining-parameterized-types-and-functions)

An example of combining theses:
#### main.py
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
    let py_mymodule = Python.import_module("main")

    @noncapturing
    fn mojo_print(p:Int)->Int:
        print(p)
        return p+1
    
    w = get_wrapper[fn(Int)->Int]("c_int",mojo_print,"c_int")
    
    py_mymodule.call_mojo_print(w)


    @noncapturing
    fn m_sum(arg:Pointer[Float64],size:Int)->Float64:
        var total:Float64 = 0.0
        for i in range(size):
            total+=arg.load(i)
        return total
    
    w2 = get_wrapper[fn(Pointer[Float64],Int)->Float64]("c_double",m_sum,"c_void_p","c_int")
    py_mymodule.call_sum(w2)
```


#### Overview:
- Create a pointer to the mojo function
- Create a PythonObject with ctype imported_module
- load the address as a CFUNCTYPE
- assign the return type and argument types from variadic list
- Pass the PythonObject into python land
- Call the PythonObject from there
- Pointer is left not freed, *need to be freed*


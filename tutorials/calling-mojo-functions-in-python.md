# 🔥🐍 calling mojo functions from python
> with 0.4.0
#### ⚠️ do no use in production, untested code, there might be bugs

It seems to show about 1.36x speedup over numpy np.sum(),

the mojo function is using vectorize and SIMD, it could be improved with parallelize.

    mojo benchmark :         0.018098020926117897
    numpy benchmark:         0.025459413998760283
    numpy result   :         24999634.312324334
    mojo result    :         24999634.31232557


The function is passed to python using a pointer, as an integer:

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
# it will hopefully help you use mojo, hand in hand with python
```python
from python import Python
from python import PythonObject
from math import math
from time import now

struct np_loader:
    var lib:PythonObject
    var loaded: Bool
    fn __init__(inout self):
        try:
            self.lib = Python.import_module("numpy")
            self.loaded = True
        except e:
            self.loaded = False
    fn __getitem__(inout self, key:StringLiteral)raises->PythonObject:
        return self.lib.__getattr__(key)

fn main() raises:
    var np = np_loader()                                        #get numpy from python
    if np.loaded:
        var python_result = np["linspace"](0, 255,256)          #get linear space from python
        var simd_mojo_array = SIMD[DType.float64,256]()         #simd is really fast
                                                   
        var pi = np["pi"].to_float64()                          # python returns PythonObject therefore they sometimes require conversion to mojo types in order to use some functions

        var size:Int=python_result.size.to_float64().to_int()   #convert arr size to mojo int
        for x in range(size):
            simd_mojo_array[x]=python_result[x].to_float64()    #from python float object to mojo float

        
        simd_mojo_array = math.cos(simd_mojo_array*(pi*2.0/256.0))    # perform the simd cos operation 

        print(simd_mojo_array)
```

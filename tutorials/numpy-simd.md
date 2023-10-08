---
title: simd cosine with np.linspace
author: rd4com
layout: page
description: import numpy using ```try:``` and ```except:``` inside a struct wrapper, meta-programming with ```__getitem__``` to get linspace, conversion to ```SIMD[DType.float64,size]```, apply ```math.cos()```
permalink: numpy-simd-meta-programming
---
The simd part need revision,
it is not good practice. update soon!
```python
from python import Python
from python import PythonObject
from math import math

struct np_loader:
    #Python.import_module("numpy") returns a PythonObject
    var lib:PythonObject
    var loaded: Bool
    fn __init__(inout self):
        try:        #let see if an error is produced
            self.lib = Python.import_module("numpy")
            self.loaded = True
        except e:   #if there was an error,don't crash, do this
            self.loaded = False
    #np["linspace"], "linspace" is the key, a StringLiteral
    fn __getitem__(inout self, key:StringLiteral)raises->PythonObject:
        #get the attribute "linspace" from the python object, and return it
        return self.lib.__getattr__(key)

fn main() raises:
    #get numpy from python
    var np = np_loader()
    #make sure there was no errors                                    
    if np.loaded:
        #get the linspace function from python and call it
        var python_result = np["linspace"](0, 255,256)          
        #prepare a simd array of 256 elements
        var simd_mojo_array = SIMD[DType.float64,256]()         

        # python returns PythonObject therefore they sometimes require
        # conversion to mojo types in order to use some functions                                                   
        var pi = np["pi"].to_float64()                          

        #convert array size to mojo int
        var size:Int=python_result.size.to_float64().to_int()
        #mojo provide range just like python, that one is a mojo one
        for x in range(size):
            #from python float object to mojo float
            simd_mojo_array[x]=python_result[x].to_float64()    

        #perform the simd cos operation 
        simd_mojo_array = math.cos(simd_mojo_array*(pi*2.0/256.0))

        print(simd_mojo_array)
```
```python
import math
from sys.info import simdwidthof
from algorithm import vectorize
from python import Python

fn main():

    alias size = 256
    alias value_type = DType.float64
    
    #allocate array of size elements of type value_type
    var array = DTypePointer[value_type]().alloc(size)
    
    @parameter
    fn cosine[group_size:Int](X: Int):
        #create a simd array of size group_size. values: X->(X+group_size-1)
        var tmp = math.iota[value_type, group_size](X)
        tmp = tmp * 3.14 * 2 / 256.0
        tmp = math.cos[value_type,group_size](tmp)
        array.simd_store[group_size](X,tmp)
    
    #how much values at a time
    alias by_group_of = simdwidthof[value_type]() 
    vectorize[by_group_of,cosine](size)
    
    for i in range(size):
        print(array.load(i))
    
    try:
        var plt = Python.import_module("matplotlib.pyplot")
        var python_y_array = PythonObject([])
        for i in range(size):
            python_y_array.append(array.load(i))
        var python_x_array = Python.evaluate("[x for x in range(256)]")
        plt.plot(python_x_array,python_y_array)
        plt.show()
    except:
        print("no plot")
    
    #release memory
    array.free()
```
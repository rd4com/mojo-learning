
# 🛣️ 🚌 multi-core (parallelize) with simd
### 🪮 parallel without simd

```python
from algorithm import parallelize
fn main():

    @parameter
    fn compute_number(x:Int): 
        print(x*x)
        
    var stop_at = 16
    var cores = 4
    
    #start at 0, end at stop_at (non inclusive)
    parallelize[compute_number](stop_at,cores)
```


# 🚍 simd
To use an analogy, thanks to @PriNova for the inspiration,

simd can be thought of as autobuses filled with numbers,

with only one instruction, we can calculate the entire autobus. (in the same amount of time it would have taken to calculate a single number in a non-simd way)

how much numbers can fit in one autobus depend on the type. (can fit more small types)

```python
import math
fn main():
    var numbers = SIMD[DType.uint8,8]()
    
    # simd instructions:

    # a. fill them with numbers from 0 to 7
    numbers = math.iota[DType.uint8,8](0)
    
    # b. x*x for each numbers
    numbers*=numbers

    print(numbers)
    
    #[0, 1, 4, 9, 16, 25, 36, 49]
```

# 🚍 🚍 🛣️ simd in parallel 

it is like 4 autobus advancing on 4 separate highway lanes toward a destination.

they reach destination more or less at the same time and in the same amount of time it would have taken with only one autobus in a single highway lane. (single core, non multi-core)


```python
from algorithm import parallelize
from memory.unsafe import DTypePointer
from sys.info import simdwidthof
import math

fn main():

    # how much highway lanes
    var computer_cores = 4

    alias element_type = DType.int32

    #how much numbers in the autobus:
    alias group_size = simdwidthof[element_type]()
    
    #how much autobus needs to travel:
    alias groups = 16

    #initialized array of numbers with random values
    var array = DTypePointer[element_type]().alloc(groups*group_size)
    
    @parameter
    fn compute_number(x:Int):
        # one autobus:
        var numbers: SIMD[element_type,group_size]
        
        # 3 simd instructions:
        numbers = math.iota[element_type,group_size](x*group_size)
        numbers *= numbers
        array.simd_store[group_size](x*group_size,numbers)


    # open the highway
    parallelize[compute_number](groups,computer_cores)
    
    #   parallelize will call compute_number with argument
    #       x= 0,1,2...groups (non-inclusive)

    for i in range(groups*group_size):
        var result = array.load(i)
        print("Index:" , i, " = ",result)

    array.free()
```

### [math.iota](https://docs.modular.com/mojo/stdlib/math/math.html#iota) fills an array with incrementing numbers.

### DTypePointer: *simd_store*
With an array of 256 elements:

set the first 8 elements:
- ```array.simd_store[DType.float32,8](0,simd_array_of_8_values)```

set the second 8 elements:
- ```array.simd_store[DType.float32,8](8,simd_array_of_8_values)```

set the third 8 elements:
- ```array.simd_store[DType.float32,8](16,simd_array_of_8_values)```

> note: the offset argument is a **multiple of 8** when storing by groups of 8.

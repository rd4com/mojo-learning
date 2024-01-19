# ```SIMD```: 🔢✖️2️⃣🟰❪2️⃣,4️⃣,6️⃣,8️⃣❫
It is to perform the same operation on multiple numbers. 



&nbsp;


### ```S.I.M.D``` is like a small array
But it has a maximum size, depending on the computer and the type.

It stands for single instruction, multiple data: ```SIMD``` can perform ```math.cos``` on multiple numbers for example. 

It is a lot faster and smaller than an array, so the iteration is usually done by taking ```32``` elements at a time, for example.


Here is a ```SIMD``` that has 8 elements of type ```DType.float32```:
```python
var x = SIMD[DType.float32,8]()

for i in range(8): x[i]=i

print(x)     #[0.0, 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0]
```
The size chosen is 8, but it can be much larger.

By default, the SIMD will use the ```maximum size``` (```width```) that permit the computer:
```python
print(simdwidthof[DType.float32]()) #8, depend on the computer
print(simdwidthof[DType.uint8]())   #32, depend on the computer
```
ℹ️ Note: sizes and types are parameters



&nbsp;
### 🔢🔨 Single instruction: multiple data
This is why ```SIMD``` is fast, it can perform an operation on many numbers "at the same time".
```python
#previously defined: var x = SIMD[DType.float32,8]()
#previously assigned: for i in range(8): x[i]=i
#value of x:            #[0.0, 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0]

print(x>3)              #[False, False, False, False, True, True, True, True]
print(x==1.0)           #[False, True, False, False, False, False, False, False]
print(x*2)              #[0.0, 2.0, 4.0, 6.0, 8.0, 10.0, 12.0, 14.0]
```
In contrast, an operation performed on a single number:
```python
var j = 1.0
j = j + 1.0
print(j>1.5)    #True
```
It is important to note that most "single" numbers are ```SIMD``` with a ```width``` of ```1``` and a ```DType```.

This is great, because it just make the whole system easy to do ```SIMD```  on demand.

For example, ```math.cos``` can be performed both on a single number and multiple numbers, only the ```width``` vary.

```python
var x = Int64(1) #SIMD[DType.int64,1]
```

&nbsp;
### math
```S.I.M.D``` has the ability to perform math in a fast way,

because operations can be performed on multiple numbers at the same time.

Here are a few ```math``` operations and reductions, there are many more:
```python
y = math.iota[DType.float32,8](0) #[0.0, 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0]
print(y.reduce_add())             #28.0
print(y*y.reduce_add())           #[0.0, 28.0, 56.0, 84.0, 112.0, 140.0, 168.0, 196.0]
print(y.reduce_max())             #7.0
print(y*y)                        #[0.0, 1.0, 4.0, 9.0, 16.0, 25.0, 36.0, 49.0]
print(math.cos(y))
print(math.sqrt(y))
#links to the documentation of mojo that contains many more math
```
(see [Documentation: math](https://docs.modular.com/mojo/stdlib/math/math.html))

&nbsp;

### utilities
It includes ```slice```, ```join```, ```rotate```, ```iota```,..

```iota``` is to create a incrementing sequence of numbers, by giving the first value:
```python
y = math.iota[DType.float32,8](0) #[0.0, 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0]
A = y.slice[4](offset=0)          #[0.0, 1.0, 2.0, 3.0]
B = y.slice[4](offset=4)          #[4.0, 5.0, 6.0, 7.0]
C = SIMD.join(B,A)                #[4.0, 5.0, 6.0, 7.0, 0.0, 1.0, 2.0, 3.0]
print(C.rotate_left[4]())         #[0.0, 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0]
```

&nbsp;

### pointers
Usually, numbers are loaded from the disk and stored in the ```RAM```,

The pointer is then used to ```simd_load``` some numbers into a ```SIMD``` value, in order to perform operations.

```python
p = DTypePointer[DType.uint8].alloc(8)

for i in range(8): p[i] = i
for i in range(8): print(p[i])  #prints 0,1,2,3,4,5,6,7 "like with arrays"

r = p.simd_load[8](0)
print(r)                        #[0, 1, 2, 3, 4, 5, 6, 7]

r = r+10
p.simd_store(r)
print(p.simd_load[8](0)) #[10, 11, 12, 13, 14, 15, 16, 17]
print(p.simd_load[4](0)) #[10, 11, 12, 13]
print(p.simd_load[4](4)) #[14, 15, 16, 17]

p.free()
```
> ℹ️ Note that mojo have [Tensors](https://docs.modular.com/mojo/stdlib/tensor/tensor.html), they can load data and are just great ! 🔥 

&nbsp;

### Casting/converting
```python
var i:Int32 = 1             #SIMD[DType.int32,1](1), one number
print(SIMD.interleave(i,0)) #[1, 0]
print(SIMD.interleave(i,0).cast[DType.bool]()) #[True,False]

var K:Int64 = 2             #SIMD[DType.int64,1], one number
var o = K.cast[DType.float32]()
print(o)                    #2.0
```

&nbsp;

### booleans
```python
values_b = SIMD[DType.bool,4](True,False,False,True)

print(math.any_true(values_b))  #True
print(math.all_true(values_b))  #False
print(values_b.reduce_or())     #True
print(values_b.reduce_and())    #False
print(~values_b)                #[False, True, True, False]
```

&nbsp;

### selection
Based on ```True``` or ```False```, select corresponding values to build a ```SIMD```.
```python
yes = SIMD[DType.int32,4](10,20,30,40)
no  = SIMD[DType.int32,4](-10,-20,-30,-40)
guide = SIMD[DType.bool,4](True,True,False,False)
res= guide.select(yes,no)
print(res) #[10, 20, -30, -40]
```

&nbsp;

### shuffle
To change the order of the values:
```python
numbers = SIMD[DType.int32,4](10,20,30,40)
print(numbers.shuffle[3,2,0,1]()) #[40, 30, 10, 20]
```



&nbsp;

### limit
The highest value supported by a ```DType```, for example.

There is also ```inf```, ```neginf``` for floats and more: see [Documentation: limit](https://docs.modular.com/mojo/stdlib/math/limit.html)



```python
#limits
print(math.limit.max_finite[DType.uint8]())  #255
print(math.limit.min_finite[DType.uint8]())  #0
print(math.limit.max_finite[DType.uint64]()) #18446744073709551615
print(math.limit.max_finite[DType.float32]())#3.4028234663852886e+38
```



&nbsp;

### 🧰👍 Many many more features, see the documentation on the website or the repo of mojo.

### 📎📖 links: [```math```](https://docs.modular.com/mojo/stdlib/math/math.html), [```SIMD```](https://docs.modular.com/mojo/stdlib/builtin/simd.html) and [```DType```](https://docs.modular.com/mojo/stdlib/builtin/dtype.html).

### There is also an [intuitive walk-trough](https://docs.modular.com/mojo/manual/) on the website of mojo.

&nbsp;

> Made by the community! 🩳

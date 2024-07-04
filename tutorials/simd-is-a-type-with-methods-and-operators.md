# `SIMD` is a type, with `methods` and `operators` !

In mojo, `SIMD` vectors are first-class citizens.

For example, `Int64` is a `SIMD` vector of size 1.

(`SIMD[DType.int64, 1]`)

&nbsp;

The `SIMD` type has `Methods`  aswel as `operators`. 


&nbsp;

#### Examples:

```mojo
print(
    4 * SIMD[DType.int8,4](1,2,3,4)
)
```
> [4, 8, 12, 16]

&nbsp;

```mojo
print(
    SIMD[DType.int32,4](1,1,2,2).reduce_add()
)
```
> 6

&nbsp;

```mojo
print(
    SIMD[DType.bool,4](True,False,True,False).reduce_and()
)
```
> false

&nbsp;

The multiply `operator` (`*`) works in an unifying manner,

with both `SIMD` vectors of size `1` and size `32`.


&nbsp;

So learning `SIMD` is just like learning an arbitraty `class` / `type`.

It has the `__add__` dunder, `__init__` and many more `methods`.

&nbsp;

&nbsp;

&nbsp;

&nbsp;


# `SIMD` on the `Stack`

```mojo
var x = SIMD[DType.float64,2](1.5, 2.5)
var y = x.reduce_add()
print(y)
```
`y` is a `Float64`.

(`SIMD[DType.float64, 1]`)

&nbsp;

There is already a small tutorial for it:

- [SIMD: 🔢✖️2️⃣🟰❪2️⃣,4️⃣,6️⃣,8️⃣❫](./simd.md)

&nbsp;

# `SIMD` on the `Heap`

Let's take for example a pointer to `10` * `Int64`.

Instead of iterating each elements to add them together,

It is also possible to do a fast addition with `SIMD` !

&nbsp;

### Preparing a `DTypePointer`

It is like a pointer, but is more specialized for `SIMD`.


We'll use `alloc`, we'll have to `free`.

```mojo
def main():
    alias amount_of_bytes = 256
    var mem = DTypePointer[DType.uint8].alloc(amount_of_bytes)
    for i in range(amount_of_bytes):
        mem[i] = i #slower but good first step !
```

&nbsp;

#### Second step: `SIMD` vector
Let's load the first 8 elements
```mojo
var bunch_of_bytes = SIMD[type=DType.uint8, size=8].load(mem)
print(bunch_of_bytes)
```
> [0, 1, 2, 3, 4, 5, 6, 7]

The data is now in a `SIMD` vector.

Let's not `free` yet, and learn more.

&nbsp;

### Stride and width
width is the size of the `SIMD` vector.

`stride` can be used with `offset`.


    0◄─────┐               
    1      │               
    2◄─────┤               
    3      │  Stride: 2    
    4◄─────┤  Width: 4     
    5      │               
    6◄─────┤               
    7      │               
           │                  
           ▼               
    [0,2,4,6] SIMD[Width:4] 

&nbsp;

#### A. The concept
```mojo
var stride_like = 2
for i in range(0,8,stride_like):
    print(i)   
```
> 0, 2, 4, 6
#### B. The SIMD stride

```mojo
var separated_by_2 = mem.simd_strided_load[width = 8](
    stride = 2
)
print(separated_by_2)
```
> [0, 2, 4, 6, 8, 10, 12, 14]

&nbsp;

Let's not `free` yet, and learn more!

&nbsp;

### `gather`

It gathers the values stored at various positions into a `SIMD` vector.

```mojo
for i in range(16):
    mem[i] = i*i

print(
    mem.gather(
        SIMD[DType.int64,4](1, 2, 5, 6)
    )
)
```
> [1, 4, 25, 36]

&nbsp;

Here is the `gather` `method` of `DTypePointer` in a visual form:

    Memory: 0 10 20 30 40 50        
            │       │  │  │     
            └─────┬─┴──┴──┘     
     Gather 0     │ 3  4  5     
                  ▼             
            [0,30,40,50]        
                            
&nbsp;

&nbsp;

### `scatter`

It assign new values to various positions.

The values are provided in a `SIMD` vector.

The positions aswel, but theses are `int64`.

```mojo
mem.scatter(
    offset = SIMD[DType.int64, 2](1,10),
    val = SIMD[DType.uint8, 2](0, 0)
)
print(mem[1])
print(mem[10])
```
> 0

> 0

&nbsp;

Here is the `scatter` `method` of `DTypePointer` in a visual form:




    Memory: 0 10 20 30 40 50    
            ▲     ▲             
            │     │             
            │     │             
         ┌──┴─────┘             
         │  0     2   Indexes   
         │  100   200 Values    
    scatter                     
           
                                  
                                       
> Memory: 100, 10, 200, 30, 40, 50         

&nbsp;

&nbsp;

# ♻️ `free`

It is a `method` of `DTypePointer`.

`alloc` gave us some `RAM` for the program,

`free` gives it back:


```mojo
mem.free()
```

Very easy to use:

        ┌──────────────────────┐                         
        │            RAM       │                         
        ├──┐                   │                         
        └┼─┴───────────────────┘                         
         │                                                
         │                                               
         ▼                                               
    alloc                                              
        ┌──┐                                             
        └──┘                                             
    our program has to give the small amount of ram back
    because another program might need it !             

&nbsp;



`free` and `alloc`

`alloc` and `free`

It is a recycling thing!

&nbsp;

Note that mojo have `Reference` to help !


&nbsp;

# math

There is a `math` module with functions that works with `SIMD`.

Theses are functions like `cos`, `floor`, `iota`, and many more.

Here is a link to the documentation:

- [Documentation: math](https://docs.modular.com/mojo/stdlib/math/math)

&nbsp;

# 🎉 End of small tutorial

Hope you enjoyed it,

`SIMD` is easy and it has many more `methods`.

Many people do `AI` with because it is realy fast,

but it is good for making music too !

&nbsp;

You don't have to use `SIMD` all the time,

but it is there if one day the program become too slow, for example.



Because `Int64` is a vector of size `1`,

only a few changes can turn the program into `SIMD` fast!

&nbsp;

Note: on most computers, a vector can be as much as `32` bytes.

It works well as a small buffer without alloc!

